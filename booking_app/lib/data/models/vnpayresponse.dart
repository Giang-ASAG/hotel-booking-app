class VNPayResponse {
  String vnp_ResponseCode;
  String vnp_TxnRef;
  String vnp_Amount;
  String vnp_BankCode;
  String vnp_OrderInfo;
  String vnp_PayDate;

  // Constructor
  VNPayResponse({
    required this.vnp_ResponseCode,
    required this.vnp_TxnRef,
    required this.vnp_Amount,
    required this.vnp_BankCode,
    required this.vnp_OrderInfo,
    required this.vnp_PayDate,
  });

  // Factory method to create an instance from JSON
  factory VNPayResponse.fromJson(Map<String, dynamic> json) {
    return VNPayResponse(
      vnp_ResponseCode: json['vnp_ResponseCode'],
      vnp_TxnRef: json['vnp_TxnRef'],
      vnp_Amount: json['vnp_Amount'],
      vnp_BankCode: json['vnp_BankCode'],
      vnp_OrderInfo: json['vnp_OrderInfo'],
      vnp_PayDate: json['vnp_PayDate'],
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'vnp_ResponseCode': vnp_ResponseCode,
      'vnp_TxnRef': vnp_TxnRef,
      'vnp_Amount': vnp_Amount,
      'vnp_BankCode': vnp_BankCode,
      'vnp_OrderInfo': vnp_OrderInfo,
      'vnp_PayDate': vnp_PayDate,
    };
  }

  @override
  String toString() {
    return 'VNPayResponse{vnp_ResponseCode: $vnp_ResponseCode, vnp_TxnRef: $vnp_TxnRef, vnp_Amount: $vnp_Amount, vnp_BankCode: $vnp_BankCode, vnp_OrderInfo: $vnp_OrderInfo, vnp_PayDate: $vnp_PayDate}';
  }
}
