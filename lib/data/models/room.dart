class Room {
  final int roomId;
  final String roomNumber;
  final bool? status;
  final int? roomTypeId;
  final bool? active;

  Room({
    required this.roomId,
    required this.roomNumber,
    this.status,
    this.roomTypeId,
    this.active,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'],
      roomNumber: json['roomNumber'],
      status: json['status'],
      roomTypeId: json['roomTypeId'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomNumber': roomNumber,
      'status': status,
      'roomTypeId': roomTypeId,
      'active': active,
    };
  }
}
