import 'package:application_book/data/core/UnitofWork.dart';
import 'package:application_book/data/di/locator.dart';
import 'package:application_book/data/models/roomtype.dart';
import 'package:application_book/screens/detail/RoomDetail_Screen.dart';
import 'package:application_book/widgets/customPopup.dart';
import 'package:application_book/widgets/loading.dart';
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final int hotelId;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;

  const RoomScreen({
    super.key,
    required this.hotelId,
    this.checkinDate,
    this.checkoutDate,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final List<RoomType> roomList = [];
  final _service = getIt<UnitOfWork>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRoom(widget.hotelId);
  }

  Future<void> fetchRoom(int id) async {
    if (widget.checkinDate != null || widget.checkoutDate != null) {
      try {
        final result = await _service.roomService.getRoomTypeBySearch(
          id,
          widget.checkinDate!,
          widget.checkoutDate!,
        );
        if (result.isNotEmpty) {
          setState(() {
            roomList.addAll(result as List<RoomType>);
          });
        } else {
          debugPrint("Không có phòng nào");
        }
      } catch (e) {
        debugPrint("Loi khi lay danh sach phong: $e");
      }
    } else {
      try {
        final result = await _service.roomService.getRoomsByHotelId(id);
        if (result.isNotEmpty) {
          setState(() {
            roomList.addAll(result as List<RoomType>);
          });
        } else {
          debugPrint("Không có phòng nào");
        }
      } catch (e) {
        debugPrint("Loi khi lay danh sach phong: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phòng'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: roomList.length,
        itemBuilder: (context, index) {
          final room = roomList[index];
          // if(room.count == 0) {
          //   WidgetsBinding.instance.addPostFrameCallback((_){
          //     showPopup(
          //         context: context,
          //         type: AlertType.none,
          //         title: "Thông báo",
          //         content: "Hiện tại khách sạn này đã hết phòng",
          //         onOkPressed: ()  {
          //           // Pop dialog (popup)
          //           Navigator.pop(context);
          //           // Sau 1 khung hình, pop tiếp để quay lại màn trước
          //           Future.microtask(() {
          //             Navigator.pop(context);
          //           });
          //         });
          //   });
          //   return const SizedBox.shrink();
          // }
          return RoomCard(
            room: room,
            checkinDate: widget.checkinDate,
            checkoutDate: widget.checkoutDate,
          );
        },
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final RoomType room;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;

  const RoomCard({
    super.key,
    required this.room,
    this.checkinDate,
    this.checkoutDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Căn chỉnh đầu dòng
              children: [
                // Hình ảnh thay cho icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    room.images![0],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame == null) {
                            return ShimmerLoading.rectangular(
                              height: 100,
                              width: 100,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            );
                          }
                          return child;
                        },
                  ),
                ),
                const SizedBox(width: 12),
                // Nội dung thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.typeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '👤 ${room.capacity}  |  ${(room.price).toStringAsFixed(0)}VND/ngày',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Phòng còn trống: ${room.count}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (room.count! > 0) ...[
                        CustomButton(
                          text: "Xem chi tiết",
                          onPressed: () {
                            btnSeeRoom(context);
                          },
                          backgroundColor: Colors.green,
                          height: 50,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void btnSeeRoom(BuildContext context) {
    if (checkinDate == null || checkoutDate == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomDetailScreen(room: room)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomDetailScreen(
            room: room,
            checkinDate: checkinDate,
            checkoutDate: checkoutDate,
          ),
        ),
      );
    }
  }
}
