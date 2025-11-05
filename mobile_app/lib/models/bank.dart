class Bank {
  final int id;
  final String bankName;
  final String? bankCode;
  final String status;
  final String createdAt;

  Bank({
    required this.id,
    required this.bankName,
    this.bankCode,
    required this.status,
    required this.createdAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: int.parse(json['id'].toString()),
      bankName: json['bank_name'] ?? '',
      bankCode: json['bank_code'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'bank_code': bankCode,
      'status': status,
      'created_at': createdAt,
    };
  }
}
