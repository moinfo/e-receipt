class Receipt {
  final int id;
  final int userId;
  final int? bankId;
  final String? bankName;
  final String receiptImagePath;
  final String? receiptNumber;
  final double amount;
  final String? description;
  final String status;
  final String uploadDate;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;

  Receipt({
    required this.id,
    required this.userId,
    this.bankId,
    this.bankName,
    required this.receiptImagePath,
    this.receiptNumber,
    required this.amount,
    this.description,
    required this.status,
    required this.uploadDate,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      bankId: json['bank_id'] != null ? int.parse(json['bank_id'].toString()) : null,
      bankName: json['bank_name'],
      receiptImagePath: json['receipt_image_path'] ?? '',
      receiptNumber: json['receipt_number'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      status: json['status'] ?? 'pending',
      uploadDate: json['upload_date'] ?? '',
      approvedBy: json['approved_by_username'],
      approvedAt: json['approved_at'],
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bank_id': bankId,
      'bank_name': bankName,
      'receipt_image_path': receiptImagePath,
      'receipt_number': receiptNumber,
      'amount': amount,
      'description': description,
      'status': status,
      'upload_date': uploadDate,
      'approved_by_username': approvedBy,
      'approved_at': approvedAt,
      'rejection_reason': rejectionReason,
    };
  }
}
