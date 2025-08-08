class Review {
  final int ReviewId;
  final int HotelId;
  final int UserId;
  final String Description;
  final String UserName;
  final int StarRating;

  Review(
      {required this.ReviewId,
      required this.HotelId,
      required this.UserId,
      required this.Description,
      required this.UserName,
      required this.StarRating});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      ReviewId: json['reviewId'] as int,
      HotelId: json['hotelId'] as int,
      UserId: json['userId'] as int,
      StarRating: json['starRating'] as int,
      Description: json['description'] as String,
      UserName: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': ReviewId,
      'hotelId': HotelId,
      'userId': UserId,
      'starRating': StarRating,
      'description': Description,
      'username': UserName,
    };
  }
}
