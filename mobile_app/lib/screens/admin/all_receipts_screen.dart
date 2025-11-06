import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';
import '../../services/admin_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/receipt_card.dart';
import '../home/receipt_detail_screen.dart';

class AllReceiptsScreen extends StatefulWidget {
  const AllReceiptsScreen({super.key});

  @override
  State<AllReceiptsScreen> createState() => _AllReceiptsScreenState();
}

class _AllReceiptsScreenState extends State<AllReceiptsScreen> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<Receipt> _receipts = [];
  String? _selectedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
    });

    String? dateFromStr;
    String? dateToStr;

    if (_dateFrom != null) {
      dateFromStr = DateFormat('yyyy-MM-dd').format(_dateFrom!);
    }
    if (_dateTo != null) {
      dateToStr = DateFormat('yyyy-MM-dd').format(_dateTo!);
    }

    final response = await _adminService.getAllReceipts(
      status: _selectedStatus,
      dateFrom: dateFromStr,
      dateTo: dateToStr,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _receipts = response['data'] as List<Receipt>;
        }
      });
    }
  }

  Future<void> _selectDateFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _dateFrom) {
      setState(() {
        _dateFrom = picked;
      });
      _loadReceipts();
    }
  }

  Future<void> _selectDateTo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _dateTo) {
      setState(() {
        _dateTo = picked;
      });
      _loadReceipts();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Filter Receipts',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGray,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: AppColors.cardBg,
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _dateFrom = null;
                _dateTo = null;
              });
              Navigator.of(context).pop();
              _loadReceipts();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadReceipts();
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('All Receipts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReceipts,
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Date Range Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          if (_selectedStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedStatus == 'approved'
                                    ? AppColors.successGreen.withOpacity(0.2)
                                    : _selectedStatus == 'rejected'
                                        ? AppColors.dangerRed.withOpacity(0.2)
                                        : AppColors.warningYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedStatus!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedStatus == 'approved'
                                      ? AppColors.successGreen
                                      : _selectedStatus == 'rejected'
                                          ? AppColors.dangerRed
                                          : AppColors.warningYellow,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateFrom,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.lightGray,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatDate(_dateFrom),
                                        style: const TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'to',
                              style: TextStyle(color: AppColors.lightGray),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateTo,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.lightGray,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatDate(_dateTo),
                                        style: const TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Receipt List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _receipts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: AppColors.lightGray.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No receipts found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.lightGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting the filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.lightGray,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReceipts,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _receipts.length,
                              itemBuilder: (context, index) {
                                final receipt = _receipts[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ReceiptCard(
                                    receipt: receipt,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiptDetailScreen(receipt: receipt),
                                        ),
                                      ).then((_) => _loadReceipts());
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
