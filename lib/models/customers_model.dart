class CustomersModel {
  final String id;
  final String username;
  final String email;
  final String role;

  CustomersModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory CustomersModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomersModel(
      id: id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
