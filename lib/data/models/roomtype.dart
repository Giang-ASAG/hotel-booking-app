class RoomType {
  final int roomTypeId;
  final String typeName;
  final String? roomInfo;
  final double price;
  final int capacity;
  final int? hotelId;
  final int? count;
  final List<String>? images;

  RoomType({
    required this.roomTypeId,
    required this.typeName,
    this.roomInfo,
    required this.price,
    required this.capacity,
    this.hotelId,
    required this.count,
    required this.images,
  });

  // Hàm fromJson để parse từ JSON
  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      roomTypeId: json['roomTypeId'],
      typeName: json['typeName'],
      roomInfo: json['roomInfo'],
      price: (json['price'] as num).toDouble(),
      capacity: json['capacity'],
      hotelId: json['hotelId'],
      count: json['count'],
      images: (json['imgPath'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  // Hàm toJson để convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'roomTypeId': roomTypeId,
      'typeName': typeName,
      'roomInfo': roomInfo,
      'price': price,
      'capacity': capacity,
      'hotelId': hotelId,
      'count': count,
      'imgPath' : images,
    };
  }

  @override
  String toString() {
    return 'Du lieu RoomType{roomTypeId: $roomTypeId, typeName: $typeName, roomInfo: $roomInfo, price: $price, capacity: $capacity, hotelId: $hotelId, count: $count, images: $images}';
  }
}
