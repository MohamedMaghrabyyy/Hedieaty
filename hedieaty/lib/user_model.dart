class UserModel {
  final String email;
  final String name;
  final String phoneNumber;

  UserModel({
    required this.email,
    required this.name,
    required this.phoneNumber,
  });

  // Convert UserModel to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
