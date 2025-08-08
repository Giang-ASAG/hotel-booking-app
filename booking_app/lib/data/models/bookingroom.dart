class BookingRoom {
  final int bkroomsId;
  final int bookingId;
  final int roomId;
  final DateTime createdAt;

  BookingRoom({
    required this.bkroomsId,
    required this.bookingId,
    required this.roomId,
    required this.createdAt
  });

  // Factory constructor để chuyển từ JSON thành đối tượng
  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      bkroomsId: json['bkroomsId'] as int,
      bookingId: json['bookingId'] as int,
      roomId: json['roomId'] as int,
      createdAt:  DateTime.parse(json['createdAt'])
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'bkroomsId': bkroomsId,
      'bookingId': bookingId,
      'roomId': roomId,
      'createdAt' : createdAt.toIso8601String()
    };
  }
}
