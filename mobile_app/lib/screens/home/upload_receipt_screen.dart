import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/bank.dart';
import '../../services/bank_service.dart';
import '../../services/receipt_service.dart';
import '../../utils/constants.dart';

class UploadReceiptScreen extends StatefulWidget {
  const UploadReceiptScreen({super.key});

  @override
  State<UploadReceiptScreen> createState() => _UploadReceiptScreenState();
}

class _UploadReceiptScreenState extends State<UploadReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final BankService _bankService = BankService();
  final ReceiptService _receiptService = ReceiptService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Bank> _banks = [];
  int? _selectedBankId;
  File? _selectedFile;
  bool _isLoading = false;
  bool _isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receiptNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    final response = await _bankService.getActiveBanks();

    if (mounted) {
      setState(() {
        _isLoadingBanks = false;
        if (response['success'] == true) {
          _banks = response['data'] as List<Bank>;
        }
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _showFilePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryOrange),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryOrange),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload, color: AppColors.primaryOrange),
              title: const Text('Choose File (Image or PDF)'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankId == null) {
      _showErrorDialog('Please select a bank');
      return;
    }

    if (_selectedFile == null) {
      _showErrorDialog('Please select a receipt image or PDF');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _receiptService.uploadReceipt(
        receiptImage: _selectedFile!,
        bankId: _selectedBankId!,
        amount: double.parse(_amountController.text),
        receiptNumber: _receiptNumberController.text.isNotEmpty
            ? _receiptNumberController.text
            : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(response['message'] ?? 'Upload failed');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text(
          'Receipt uploaded successfully! It will be reviewed by an admin.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Receipt'),
      ),
      body: _isLoadingBanks
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // File Picker
                    GestureDetector(
                      onTap: _showFilePicker,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: _selectedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _selectedFile!.path.endsWith('.pdf')
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              size: 64,
                                              color: AppColors.primaryOrange,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'PDF Selected',
                                              style: TextStyle(
                                                color: AppColors.lightGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Image.file(
                                        _selectedFile!,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: AppColors.lightGray,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to select receipt',
                                    style: TextStyle(
                                      color: AppColors.lightGray,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Image or PDF (max 10MB)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.lightGray,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bank Selection
                    DropdownButtonFormField<int>(
                      value: _selectedBankId,
                      decoration: const InputDecoration(
                        labelText: 'Select Bank *',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: _banks
                          .map((bank) => DropdownMenuItem(
                                value: bank.id,
                                child: Text(bank.bankName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBankId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a bank';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Receipt Number
                    TextFormField(
                      controller: _receiptNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Receipt Number (Optional)',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Upload Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _uploadReceipt,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text('Upload Receipt'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
