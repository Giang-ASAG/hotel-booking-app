import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/roomservice.dart';
import 'package:booking_app/data/models/roomtype.dart';
import 'package:booking_app/screens/detail/BookingDetail_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:booking_app/widgets/imagepage.dart';
import 'package:booking_app/widgets/loading.dart';
import 'package:flutter/material.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomType room;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;

  const RoomDetailScreen(
      {super.key, required this.room, this.checkinDate, this.checkoutDate});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final List<RoomServices> roomservices = [];
  final _service = getIt<UnitOfWork>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRoomServices();
  }

  Future<void> fetchRoomServices() async {
    try {
      final result = await _service.roomService
          .getRoomServiceByIdRoom(widget.room.roomTypeId);
      if (result.isNotEmpty) {
        setState(() {
          roomservices.addAll(result as List<RoomServices>);
        });
      } else {
        debugPrint("Không có dịch vụ nào cho phòng này");
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy dịch vụ phòng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(8, 0, 8, 20),
        child: CustomButton(
          text: "Đặt phòng",
          onPressed: () => btnBookRoom(context),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('Chi tiết phòng'),
      backgroundColor: Colors.blue,
      centerTitle: true,
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImagePlaceholder(),
          const SizedBox(height: 16),
          buildRoomInfo(),
          const SizedBox(height: 16),
          buildServices(),
          const SizedBox(height: 16),
          buildRoomDetails(),
        ],
      ),
    );
  }

  void btnBookRoom(BuildContext context) {
    if (widget.checkinDate == null || widget.checkoutDate == null) {
      showDateRangeDialog(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailScreen(
              room: widget.room,
              checkinDate: widget.checkinDate!,
              checkoutDate: widget.checkoutDate!),
        ),
      );
    }
  }

  Future<void> showDateRangeDialog(BuildContext context) async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      saveText: 'Xác nhận',
      helpText: 'Chọn ngày nhận và trả phòng',
    );

    if (pickedRange != null) {
      final checkIn = pickedRange.start;
      final checkOut = pickedRange.end;
      print('Check-in: $checkIn, Check-out: $checkOut');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailScreen(
            room: widget.room,
            checkoutDate: checkOut,
            checkinDate: checkIn,
          ),
        ),
      );
    }
  }

  Widget buildImagePlaceholder() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: widget.room.images != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PageView.builder(
            itemCount: widget.room.images!.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.room.images![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImagePage(
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame == null) {
                      return ShimmerLoading.circular(
                          width: double.infinity,
                          height: double.infinity,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ));
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(
                      child: Icon(Icons.broken_image,
                          size: 100, color: Colors.grey)),
                ),
              );
            },
          ),
        )
            : Center(
          child: Text(
            'Image Placeholder',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }


  Widget buildRoomInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.room.typeName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text('${(widget.room.price).toStringAsFixed(0)}VND/ngày'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.person, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text('Sức chứa: ${widget.room.capacity} người'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.hotel, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text('Phòng còn trống: ${widget.room.count}'),
          ],
        ),
      ],
    );
  }

  Widget buildRoomDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mô tả",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.room.roomInfo ?? "Không có thông tin mô tả",
          style: const TextStyle(fontSize: 14),
          softWrap: true,
        ),
      ],
    );
  }

  Widget buildServices() {
    if (roomservices.isEmpty) {
      return const Center(
        child: Text("Không có dịch vụ nào"),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dịch vụ và Tiện ích",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: roomservices.map((index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24, // 2 cột
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      index.serviceName!,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
