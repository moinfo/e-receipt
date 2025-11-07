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
    setState(() {
      _isLoading = true;
    });

    final response = await _bankService.getActiveBanks();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _banks = response['data'] as List<Bank>;
        }
      });
    }
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
                        padding: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }
}
