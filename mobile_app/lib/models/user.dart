class User {
  final int id;
  final String fullName;
  final String phone;
  final String username;
  final bool isAdmin;
  final String status;
  final String createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.username,
    required this.isAdmin,
    required this.status,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      username: json['username'] ?? '',
      isAdmin: json['is_admin'].toString() == '1',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'username': username,
      'is_admin': isAdmin ? 1 : 0,
      'status': status,
      'created_at': createdAt,
    };
  }
}
