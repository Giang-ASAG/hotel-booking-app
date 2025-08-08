class RoomServices {
  final int serviceId;
  final String? serviceName;
  final int? roomTypeId;

  RoomServices({
    required this.serviceId,
    this.serviceName,
    this.roomTypeId,
  });

  factory RoomServices.fromJson(Map<String, dynamic> json) {
    return RoomServices(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      roomTypeId: json['roomTypeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'roomTypeId': roomTypeId,
    };
  }
}
