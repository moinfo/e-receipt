import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';
import '../../services/receipt_service.dart';
import '../../utils/constants.dart';
import '../../widgets/receipt_card.dart';
import '../../widgets/glass_card.dart';
import 'receipt_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBottomNav;

  const HistoryScreen({super.key, this.showBottomNav = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ReceiptService _receiptService = ReceiptService();

  bool _isLoading = true;
  List<Receipt> _receipts = [];
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    // Set default dates to today
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, now.day);
    _dateTo = DateTime(now.year, now.month, now.day);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
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

    final response = await _receiptService.getUserHistory(
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
      _loadHistory();
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
      _loadHistory();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.showBottomNav ? null : AppBar(
        title: const Text('Receipt History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
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
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
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
                              'Try adjusting the date range',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.lightGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
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
                                  );
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
