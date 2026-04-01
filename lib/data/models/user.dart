class User {
  final int userId;
  final String? fullName;
  final String email;
  final String? address;
  final String? phoneNumber;

  User({
    required this.userId,
    this.fullName,
    required this.email,
    this.address,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
    );
  }
  factory User.fromJsonToken(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      fullName: json['name'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }
}
