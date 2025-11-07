import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/receipt.dart';
import '../../services/receipt_service.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();
  late Receipt _receipt;
  bool _isUpdating = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  Color _getStatusColor() {
    switch (_receipt.status) {
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
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'TZS ${formatter.format(amount)}';
  }

  Future<void> _updateReceiptStatus(String status) async {
    String? rejectionReason;

    if (status == 'rejected') {
      // Show rejection reason dialog
      rejectionReason = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            backgroundColor: AppColors.darkBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Rejection Reason',
              style: TextStyle(color: AppColors.white),
            ),
            content: TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Enter reason for rejection',
                hintStyle: TextStyle(color: AppColors.lightGray),
              ),
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
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text(
                  'Reject',
                  style: TextStyle(color: AppColors.dangerRed),
                ),
              ),
            ],
          );
        },
      );

      if (rejectionReason == null || rejectionReason.isEmpty) {
        return; // User cancelled
      }
    }

    // Confirm action
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${status == 'approved' ? 'Approve' : 'Reject'} Receipt',
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this receipt?',
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

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    final response = await _adminService.updateReceiptStatus(
      _receipt.id,
      status,
      reason: rejectionReason,
    );

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

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
        // Go back to refresh the list
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _downloadReceipt() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Download the file first
      final receiptService = ReceiptService();
      final imageUrl = receiptService.getReceiptImageUrl(_receipt.receiptImagePath);
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // For Android, use app-specific directory (no permission needed)
        // For iOS, use documents directory
        Directory? directory;
        String locationMessage;

        if (Platform.isAndroid) {
          // Use app-specific external storage (no permission required on Android 10+)
          directory = await getExternalStorageDirectory();

          // Try to use Downloads folder if permission is available
          if (directory != null) {
            // Create a Downloads subfolder in app directory
            final downloadsDir = Directory('${directory.path}/Downloads');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            directory = downloadsDir;
            locationMessage = 'Saved to app folder';
          } else {
            locationMessage = 'Saved to app storage';
          }
        } else {
          // iOS
          directory = await getApplicationDocumentsDirectory();
          locationMessage = 'Saved to Documents';
        }

        if (directory != null) {
          // Create filename with timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = _receipt.receiptImagePath.split('.').last;
          final fileName = 'receipt_${_receipt.id}_$timestamp.$extension';
          final filePath = '${directory.path}/$fileName';

          // Save file
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Receipt downloaded: $fileName\n$locationMessage'),
                backgroundColor: AppColors.successGreen,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download receipt'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading receipt: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _shareReceipt() async {
    try {
      final receiptService = ReceiptService();
      final imageUrl = receiptService.getReceiptImageUrl(_receipt.receiptImagePath);

      // Download the file to temp directory
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final extension = _receipt.receiptImagePath.split('.').last;
        final fileName = 'receipt_${_receipt.id}.$extension';
        final filePath = '${tempDir.path}/$fileName';

        // Save file temporarily
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Share the file
        final receiptInfo = '''
Receipt Details:
Bank: ${_receipt.bankName ?? 'N/A'}
Amount: ${_formatCurrency(_receipt.amount)}
Receipt #: ${_receipt.receiptNumber ?? 'N/A'}
Date: ${_formatDate(_receipt.uploadDate)}
Status: ${_receipt.status.toUpperCase()}
        ''';

        await Share.shareXFiles(
          [XFile(filePath)],
          text: receiptInfo,
          subject: 'Receipt #${_receipt.id}',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load receipt for sharing'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing receipt: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptService = ReceiptService();
    final imageUrl = receiptService.getReceiptImageUrl(_receipt.receiptImagePath);
    final isAdmin = _authService.isAdmin();

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
                if (_receipt.receiptImagePath.toLowerCase().endsWith('.pdf'))
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: AppColors.cardBg,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Image loading error: $error');
                        print('Image URL: $imageUrl');
                        return Container(
                          height: 300,
                          color: AppColors.cardBg,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 64,
                                  color: AppColors.dangerRed,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: AppColors.lightGray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    error.toString(),
                                    style: const TextStyle(
                                      color: AppColors.lightGray,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                            _receipt.status.toUpperCase(),
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
                          value: _formatCurrency(_receipt.amount),
                          valueColor: AppColors.primaryOrange,
                          valueSize: 28,
                        ),

                        const Divider(height: 32),

                        // Bank
                        if (_receipt.bankName != null)
                          _buildInfoRow(
                            icon: Icons.account_balance,
                            label: 'Bank',
                            value: _receipt.bankName!,
                          ),

                        const SizedBox(height: 16),

                        // Receipt Number
                        if (_receipt.receiptNumber != null)
                          _buildInfoRow(
                            icon: Icons.receipt,
                            label: 'Receipt Number',
                            value: _receipt.receiptNumber!,
                          ),

                        const SizedBox(height: 16),

                        // Upload Date
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Upload Date',
                          value: _formatDate(_receipt.uploadDate),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        if (_receipt.description != null && _receipt.description!.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.description,
                            label: 'Description',
                            value: _receipt.description!,
                          ),

                        // Approval Info
                        if (_receipt.status == 'approved' && _receipt.approvedBy != null) ...[
                          const Divider(height: 32),
                          _buildInfoRow(
                            icon: Icons.check_circle,
                            label: 'Approved By',
                            value: _receipt.approvedBy!,
                          ),
                          if (_receipt.approvedAt != null) ...[
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.access_time,
                              label: 'Approved At',
                              value: _formatDate(_receipt.approvedAt!),
                            ),
                          ],
                        ],

                        // Rejection Info
                        if (_receipt.status == 'rejected') ...[
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
                                  _receipt.rejectionReason ?? 'No reason provided',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                                if (_receipt.approvedBy != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejected by: ${_receipt.approvedBy}',
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

                        // Admin Actions
                        if (isAdmin && _receipt.status == 'pending') ...[
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isUpdating ? null : () => _updateReceiptStatus('approved'),
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
                                  onPressed: _isUpdating ? null : () => _updateReceiptStatus('rejected'),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _downloadReceipt,
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.download, size: 20),
                    label: Text(_isDownloading ? 'Downloading...' : 'Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareReceipt,
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
