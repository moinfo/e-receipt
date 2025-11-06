import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/receipt_service.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/glass_card.dart';
import '../auth/login_screen.dart';
import 'history_screen.dart';
import 'upload_receipt_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const DashboardScreen({super.key, this.showBottomNav = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final ReceiptService _receiptService = ReceiptService();

  bool _isLoading = true;
  Map<String, dynamic>? _statistics;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _userData = _authService.getCurrentUser();

    // Debug: Print the is_admin value and its type
    print('DEBUG: is_admin value: ${_userData['is_admin']}');
    print('DEBUG: is_admin type: ${_userData['is_admin'].runtimeType}');

    final response = await _receiptService.getUserStatistics();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _statistics = response['data'];
        }
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0.0;
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: widget.showBottomNav
          ? null
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          if (!widget.showBottomNav)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Card
                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userData['full_name'] ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${_userData['username'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightGray,
                                      ),
                                    ),
                                    if (_userData['is_admin'] == true) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOrange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'ADMIN',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Statistics Section - Different for Admin and User
                        if (_authService.isAdmin())
                          _buildAdminStatistics()
                        else
                          _buildUserStatistics(),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Statistics Header
        const Text(
          'User Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),

        // User Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              label: 'Total Users',
              value: _statistics?['user_stats']?['total_users']?.toString() ?? '0',
              icon: Icons.people,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Pending Approval',
              value: _statistics?['user_stats']?['pending_users']?.toString() ?? '0',
              icon: Icons.pending,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Approved Users',
              value: _statistics?['user_stats']?['approved_users']?.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Rejected Users',
              value: _statistics?['user_stats']?['rejected_users']?.toString() ?? '0',
              icon: Icons.cancel,
              color: AppColors.primaryOrange,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Receipt Statistics Header
        const Text(
          'Receipt Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Receipt Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              label: 'Total Receipts',
              value: _statistics?['receipt_stats']?['total_receipts']?.toString() ?? '0',
              icon: Icons.receipt_long,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Active Uploaders',
              value: _statistics?['receipt_stats']?['active_uploaders']?.toString() ?? '0',
              icon: Icons.people_outline,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Banks in Use',
              value: _statistics?['receipt_stats']?['banks_in_use']?.toString() ?? '0',
              icon: Icons.account_balance,
              color: AppColors.primaryOrange,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Total Amount Card
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  size: 28,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.lightGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(_statistics?['receipt_stats']?['total_amount'] ?? 0),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Statistics Header
        const Text(
          'My Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),

        // User Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              label: 'Total Receipts',
              value: _statistics?['total_receipts']?.toString() ?? '0',
              icon: Icons.receipt_long,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Banks Used',
              value: _statistics?['banks_used']?.toString() ?? '0',
              icon: Icons.account_balance,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Total Amount',
              value: _formatCurrency(_statistics?['total_amount'] ?? 0),
              icon: Icons.attach_money,
              color: AppColors.primaryOrange,
            ),
            StatCard(
              label: 'Last Upload',
              value: _statistics?['last_upload'] != null
                  ? DateFormat('MMM dd, yyyy').format(
                      DateTime.parse(_statistics!['last_upload']))
                  : 'N/A',
              icon: Icons.calendar_today,
              color: AppColors.primaryOrange,
            ),
          ],
        ),
      ],
    );
  }
}
