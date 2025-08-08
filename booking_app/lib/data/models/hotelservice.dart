class HotelService {
  final int serviceId;
  final int? hotelId;
  final String serviceName;
  final String? serviceInfo;

  HotelService({
    required this.serviceId,
    this.hotelId,
    required this.serviceName,
    this.serviceInfo,
  });

  factory HotelService.fromJson(Map<String, dynamic> json) {
    return HotelService(
      serviceId: json['serviceId'] as int,
      hotelId: json['hotelId'] as int?,
      serviceName: json['serviceName'] as String,
      serviceInfo: json['serviceInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'hotelId': hotelId,
      'serviceName': serviceName,
      'serviceInfo': serviceInfo,
    };
  }
}
