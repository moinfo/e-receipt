import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/receipt.dart';
import '../../services/receipt_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  Color _getStatusColor() {
    switch (receipt.status) {
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final receiptService = ReceiptService();
    final imageUrl = receiptService.getReceiptImageUrl(receipt.receiptImagePath);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Receipt Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Receipt Image
                if (receipt.receiptImagePath.toLowerCase().endsWith('.pdf'))
                  Container(
                    height: 300,
                    color: AppColors.cardBg,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 100,
                          color: AppColors.primaryOrange,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'PDF Receipt',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      // Show full screen image
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.black,
                            ),
                            body: Container(
                              color: Colors.black,
                              child: Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    imageUrl,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.error,
                                          size: 64,
                                          color: AppColors.dangerRed,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      imageUrl,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: AppColors.cardBg,
                          child: const Center(
                            child: Icon(
                              Icons.error,
                              size: 64,
                              color: AppColors.dangerRed,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            receipt.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Amount
                        _buildInfoRow(
                          icon: Icons.attach_money,
                          label: 'Amount',
                          value: _formatCurrency(receipt.amount),
                          valueColor: AppColors.primaryOrange,
                          valueSize: 28,
                        ),

                        const Divider(height: 32),

                        // Bank
                        if (receipt.bankName != null)
                          _buildInfoRow(
                            icon: Icons.account_balance,
                            label: 'Bank',
                            value: receipt.bankName!,
                          ),

                        const SizedBox(height: 16),

                        // Receipt Number
                        if (receipt.receiptNumber != null)
                          _buildInfoRow(
                            icon: Icons.receipt,
                            label: 'Receipt Number',
                            value: receipt.receiptNumber!,
                          ),

                        const SizedBox(height: 16),

                        // Upload Date
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Upload Date',
                          value: _formatDate(receipt.uploadDate),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        if (receipt.description != null && receipt.description!.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.description,
                            label: 'Description',
                            value: receipt.description!,
                          ),

                        // Approval Info
                        if (receipt.status == 'approved' && receipt.approvedBy != null) ...[
                          const Divider(height: 32),
                          _buildInfoRow(
                            icon: Icons.check_circle,
                            label: 'Approved By',
                            value: receipt.approvedBy!,
                          ),
                          if (receipt.approvedAt != null) ...[
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.access_time,
                              label: 'Approved At',
                              value: _formatDate(receipt.approvedAt!),
                            ),
                          ],
                        ],

                        // Rejection Info
                        if (receipt.status == 'rejected') ...[
                          const Divider(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.dangerRed.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.info,
                                      size: 20,
                                      color: AppColors.dangerRed,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Rejection Reason',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dangerRed,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  receipt.rejectionReason ?? 'No reason provided',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                                if (receipt.approvedBy != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejected by: ${receipt.approvedBy}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.lightGray,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    double? valueSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.lightGray,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.lightGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize ?? 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
