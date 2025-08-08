class Booking {
  final int? bookingId;
  final int? userId;
  final String checkInDate;
  final String checkOutDate;
  final double totalAmount;
  final int? status;

  Booking({
    this.bookingId,
    this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalAmount,
    this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'],
      userId: json['userId'],
      checkInDate: json['checkInDate'],
      checkOutDate: json['checkOutDate'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'totalAmount': totalAmount,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Booking{bookingId: $bookingId, userId: $userId, checkInDate: $checkInDate, checkOutDate: $checkOutDate, totalAmount: $totalAmount, status: $status}';
  }
}

class BookingMVVM {
  final int? bookingId;
  final int? userId;
  final String checkInDate;
  final String checkOutDate;
  final double totalAmount;
  final int? status;
  final int? hotelId;
  final int? roomTypeId;

  BookingMVVM(
      {this.bookingId,
      this.userId,
      required this.checkInDate,
      required this.checkOutDate,
      required this.totalAmount,
      this.status,
      this.hotelId,
      this.roomTypeId});

  factory BookingMVVM.fromJson(Map<String, dynamic> json) {
    return BookingMVVM(
      bookingId: json['bookingId'],
      userId: json['userId'],
      checkInDate: json['checkInDate'],
      checkOutDate: json['checkOutDate'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      hotelId: json['hotelId'],
      roomTypeId: json['roomTypeId'],
    );
  }


  @override
  String toString() {
    return 'Booking{bookingId: $bookingId, userId: $userId, checkInDate: $checkInDate, checkOutDate: $checkOutDate, totalAmount: $totalAmount, status: $status}';
  }
}
enum BookingStatus {
  chuaThanhToan,  // 0
  daThanhToan,    // 1
  huy,            // 2
  daNhan,         // 3
}

