import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _adminService.getPendingUsers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _users = response['data'] as List<User>;
        }
      });
    }
  }

  Future<void> _updateUserStatus(User user, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${status == 'approved' ? 'Approve' : 'Reject'} User',
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} ${user.fullName}?',
          style: const TextStyle(color: AppColors.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              status == 'approved' ? 'Approve' : 'Reject',
              style: TextStyle(
                color: status == 'approved'
                    ? AppColors.successGreen
                    : AppColors.dangerRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _adminService.updateUserStatus(user.id, status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Status updated'),
            backgroundColor: response['success'] == true
                ? AppColors.successGreen
                : AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (response['success'] == true) {
          _loadPendingUsers();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pending Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingUsers,
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pending_actions,
                            size: 64,
                            color: AppColors.lightGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No pending users',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.lightGray,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUserCard(user),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 16,
                color: AppColors.lightGray,
              ),
              const SizedBox(width: 8),
              Text(
                user.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.lightGray,
              ),
              const SizedBox(width: 8),
              Text(
                'Registered: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(user.createdAt))}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateUserStatus(user, 'approved'),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateUserStatus(user, 'rejected'),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
