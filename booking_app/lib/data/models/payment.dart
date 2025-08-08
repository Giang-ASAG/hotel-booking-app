class Payment {
  final int paymentId;
  final int? bookingId;
  final DateTime? paymentDate;
  final String? note;
  final double totalAmount;
  final String? paymentMethod;

  Payment({
    required this.paymentId,
    this.bookingId,
    this.paymentDate,
    this.note,
    required this.totalAmount,
    this.paymentMethod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      bookingId: json['bookingId'],
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
      note: json['note'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'paymentDate': paymentDate?.toIso8601String(),
      'note': note,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }
}
