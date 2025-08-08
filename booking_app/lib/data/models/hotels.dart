class Hotel {
  final int hotelId;
  final int? userId;
  final String hotelName;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? description;
  final double? xCoordinate;
  final double? yCoordinate;
  final bool? status;
  final double? star;
  final List<String >? imagePaths;

  Hotel({
    required this.hotelId,
    this.userId,
    required this.hotelName,
    this.address,
    this.phoneNumber,
    this.email,
    this.description,
    this.xCoordinate,
    this.yCoordinate,
    this.status,
    this.star,
    this.imagePaths,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      hotelId: json['hotelId'],
      userId: json['userId'],
      hotelName: json['hotelName'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      description: json['description'],
      xCoordinate: (json['xCoordinate'] as num?)?.toDouble(),
      yCoordinate: (json['yCoordinate'] as num?)?.toDouble(),
      star: json['star'],
      status: json['status'],
      imagePaths: (json['imagePaths'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelId': hotelId,
      'userId': userId,
      'hotelName': hotelName,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'description': description,
      'xCoordinate': xCoordinate,
      'yCoordinate': yCoordinate,
      'star' :star,
      'status': status,
      'imagePaths': imagePaths,
    };
  }
}
