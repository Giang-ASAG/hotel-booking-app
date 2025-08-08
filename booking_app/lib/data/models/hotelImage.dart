class HotelImage {
  int hotelImageId;
  int? hotelId;
  int? imageId;

  HotelImage({
    required this.hotelImageId,
    this.hotelId,
    this.imageId,
  });

  factory HotelImage.fromJson(Map<String, dynamic> json) {
    return HotelImage(
      hotelImageId: json['hotelImageId'] as int,
      hotelId: json['hotelId'] as int?,
      imageId: json['imageId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelImageId': hotelImageId,
      'hotelId': hotelId,
      'imageId': imageId,
    };
  }
}