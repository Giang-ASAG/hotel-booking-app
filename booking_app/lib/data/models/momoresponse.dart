class MomoResponse {
  String orderId;
  String requestId;
  int resultCode;
  String payUrl;
  String deeplink;
  String qrCodeUrl;

  MomoResponse({
    required this.orderId,
    required this.requestId,
    required this.resultCode,
    required this.payUrl,
    required this.deeplink,
    required this.qrCodeUrl,
  });

  factory MomoResponse.fromJson(Map<String, dynamic> json) {
    return MomoResponse(
      orderId: json['orderId'],
      requestId: json['requestId'],
      resultCode: json['resultCode'],
      payUrl: json['payUrl'],
      deeplink: json['deeplink'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'requestId': requestId,
      'resultCode': resultCode,
      'payUrl': payUrl,
      'deeplink': deeplink,
      'qrCodeUrl': qrCodeUrl,
    };
  }

  @override
  String toString() {
    return 'MomoResponse{orderId: $orderId, requestId: $requestId, resultCode: $resultCode, payUrl: $payUrl, deeplink: $deeplink, qrCodeUrl: $qrCodeUrl}';
  }
}