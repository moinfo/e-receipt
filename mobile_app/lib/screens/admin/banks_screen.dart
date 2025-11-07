import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bank.dart';
import '../../services/bank_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';

class BanksScreen extends StatefulWidget {
  final bool showBottomNav;

  const BanksScreen({super.key, this.showBottomNav = true});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  final BankService _bankService = BankService();

  bool _isLoading = true;
  List<Bank> _banks = [];

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _bankService.getAllBanks();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        _banks = response['data'] as List<Bank>;
      }
    });
  }

  void _showAddBankDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add New Bank',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Bank Code (Optional)',
                hintText: 'Enter bank code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter bank name'),
                    backgroundColor: AppColors.dangerRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              // Save scaffold messenger reference before closing dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final response = await _bankService.createBank(
                bankName: nameController.text.trim(),
                bankCode: codeController.text.trim().isEmpty
                    ? null
                    : codeController.text.trim(),
              );

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(response['message'] ?? 'Bank added'),
                  backgroundColor: response['success'] == true
                      ? AppColors.successGreen
                      : AppColors.dangerRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              if (response['success'] == true) {
                _loadBanks();
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBankDialog(Bank bank) {
    final nameController = TextEditingController(text: bank.bankName);
    final codeController = TextEditingController(text: bank.bankCode ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Edit Bank',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Bank Code (Optional)',
                hintText: 'Enter bank code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter bank name'),
                    backgroundColor: AppColors.dangerRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              // Save scaffold messenger reference before closing dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();

              final response = await _bankService.updateBank(
                bankId: bank.id,
                bankName: nameController.text.trim(),
                bankCode: codeController.text.trim().isEmpty
                    ? null
                    : codeController.text.trim(),
              );

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(response['message'] ?? 'Bank updated'),
                  backgroundColor: response['success'] == true
                      ? AppColors.successGreen
                      : AppColors.dangerRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              if (response['success'] == true) {
                _loadBanks();
              }
            },
            child: const Text(
              'Update',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBank(Bank bank) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Bank',
          style: TextStyle(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${bank.bankName}?',
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
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _bankService.deleteBank(bank.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Bank deleted'),
          backgroundColor: response['success'] == true
              ? AppColors.successGreen
              : AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (response['success'] == true) {
        _loadBanks();
      }
    }
  }

  Future<void> _restoreBank(Bank bank) async {
    final response = await _bankService.restoreBank(bank.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? 'Bank restored'),
        backgroundColor: response['success'] == true
            ? AppColors.successGreen
            : AppColors.dangerRed,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (response['success'] == true) {
      _loadBanks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Banks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBanks,
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _banks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance,
                            size: 64,
                            color: AppColors.lightGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No banks found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.lightGray,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBanks,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _banks.length,
                        itemBuilder: (context, index) {
                          final bank = _banks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBankCard(bank),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: widget.showBottomNav
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                onPressed: _showAddBankDialog,
                backgroundColor: AppColors.primaryOrange,
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            )
          : FloatingActionButton(
              onPressed: _showAddBankDialog,
              backgroundColor: AppColors.primaryOrange,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildBankCard(Bank bank) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.account_balance,
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
                  bank.bankName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                if (bank.bankCode != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${bank.bankCode}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.lightGray,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Added: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(bank.createdAt))}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: bank.status == 'active'
                  ? AppColors.successGreen.withOpacity(0.2)
                  : AppColors.lightGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bank.status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: bank.status == 'active'
                    ? AppColors.successGreen
                    : AppColors.lightGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.lightGray,
            ),
            color: AppColors.cardBg,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditBankDialog(bank);
                  break;
                case 'delete':
                  _deleteBank(bank);
                  break;
                case 'restore':
                  _restoreBank(bank);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primaryOrange, size: 20),
                    SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: AppColors.white)),
                  ],
                ),
              ),
              if (bank.status == 'active')
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.dangerRed, size: 20),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
              if (bank.status != 'active')
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore, color: AppColors.successGreen, size: 20),
                      SizedBox(width: 12),
                      Text('Restore', style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
