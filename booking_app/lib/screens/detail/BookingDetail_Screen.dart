import 'dart:math';

import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/booking.dart';
import 'package:booking_app/data/models/bookingroom.dart';
import 'package:booking_app/data/models/hotels.dart';
import 'package:booking_app/data/models/room.dart';
import 'package:booking_app/data/models/roomtype.dart';
import 'package:booking_app/data/models/user.dart';
import 'package:booking_app/screens/detail/UserDetail_Screen.dart';
import 'package:booking_app/screens/history/BookingHistory_Screen.dart';
import 'package:booking_app/screens/main/Main_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetailScreen extends StatefulWidget {
  final RoomType room;
  final DateTime checkinDate;
  final DateTime checkoutDate;

  const BookingDetailScreen({
    super.key,
    required this.room,
    required this.checkinDate,
    required this.checkoutDate,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  Hotel? hotel; // Initialize hotel to null
  double price = 0; // Make sure to initialize this
  final TextEditingController priceController = TextEditingController();
  int? selectedRoom;
  final _service = getIt<UnitOfWork>();
  bool isLoading = true;
  User? currentUser;

  @override
  void dispose() {
    priceController.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchHotelsbyId();
    checkInDate = widget.checkinDate;
    checkOutDate = widget.checkoutDate;
    priceController.text = "0 VND";
  }

  Future<void> fetchHotelsbyId() async {
    try {
      final result =
          await _service.hotelsService.getHotelById(widget.room.hotelId!);
      if (result != null) {
        setState(() {
          hotel = result;
          isLoading = false;
        });
        debugPrint("Khách sạn đã được lấy thành công: ${hotel!.hotelName}");
      } else {
        setState(() {
          isLoading = true;
        });
        debugPrint("Không có khách sạn nào");
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy khách sạn: $e");
    }
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final initialDate = isCheckIn
        ? (checkInDate ?? DateTime.now())
        : (checkOutDate ?? checkInDate?.add(const Duration(days: 1)));
    final firstDate = isCheckIn
        ? DateTime.now()
        : (checkInDate ?? DateTime.now()).add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          if (checkOutDate != null &&
              checkOutDate!.isBefore(picked.add(const Duration(days: 1)))) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  Widget _buildDateSelector(
      String label, DateTime? selectedDate, bool isCheckIn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          GestureDetector(
            //onTap: () => _selectDate(isCheckIn),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : 'Select date',
                    style: TextStyle(
                        color:
                            selectedDate != null ? Colors.black : Colors.grey),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOfRoomsInput(
      String label, TextEditingController controller, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
              keyboardType: TextInputType.number,
              readOnly: isReadOnly,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
              controller: controller),
        ],
      ),
    );
  }

  Widget _buildRoomCountSelection({
    required String label,
    required int roomCount,
    required int? selectedValue,
    required void Function(int?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          AbsorbPointer(
            absorbing: false,
            child: DropdownButtonFormField<int>(
              value: selectedValue,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: List.generate(roomCount, (index) {
                final value = index + 1;
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Thông tin đặt phòng"),
          backgroundColor: Colors.blue,
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 16),
                  Text(hotel!.hotelName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.room.typeName,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildDateSelector("Ngày nhận", checkInDate, true),
                  _buildDateSelector("Ngày trả", checkOutDate, false),
                  _buildRoomCountSelection(
                      label: "Số lượng phòng",
                      roomCount: widget.room.count!,
                      selectedValue: selectedRoom,
                      onChanged: (value) {
                        setState(() {
                          selectedRoom = value;
                          debugPrint("Số lượng phòng đã chọn: $selectedRoom");
                          if (checkOutDate!.month > checkInDate!.month) {
                            if (checkInDate!.month == 1 ||
                                checkInDate!.month == 3 ||
                                checkInDate!.month == 5 ||
                                checkInDate!.month == 7 ||
                                checkInDate!.month == 8 ||
                                checkInDate!.month == 10 ||
                                checkInDate!.month == 12) {
                              final result =
                                  (31 - checkInDate!.day) + checkOutDate!.day;
                              price =
                                  widget.room.price * result * selectedRoom!;
                            } else if (checkInDate!.month == 4 ||
                                checkInDate!.month == 6 ||
                                checkInDate!.month == 9 ||
                                checkInDate!.month == 11) {
                              final result =
                                  (30 - checkInDate!.day) + checkOutDate!.day;
                              price =
                                  widget.room.price * result * selectedRoom!;
                            } else {
                              final result =
                                  (28 - checkInDate!.day) + checkOutDate!.day;
                              price =
                                  widget.room.price * result * selectedRoom!;
                            }
                          } else {
                            price = widget.room.price *
                                (checkOutDate!.day - checkInDate!.day) *
                                selectedRoom!;
                          }

                          priceController.text =
                              price.toStringAsFixed(0) + " VND";
                        });
                      }),
                  _buildPriceOfRoomsInput(
                      "Tổng tiền phòng", priceController, true),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Đặt phòng",
                    onPressed: () => _btnbookRoom(context),
                  ),
                ],
              ),
      ),
    );
  }

  Future<List<Room>> fetchRandomRoom(int id, int count) async {
    try {
      final result = await _service.roomService.getRandomRoom(id, count);
      if (result.isNotEmpty) {
        return result as List<Room>;
      } else {
        debugPrint("Không có phòng nào phù hợp");
        return [];
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy phòng ngẫu nhiên: $e");
      return [];
    }
  }

  void _btnbookRoom(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString('iduser');
    if (checkInDate == null || checkOutDate == null || selectedRoom == null) {
      debugPrint("Day la id $idString");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin đặt phòng.")));
      return;
    }
    if (checkOutDate!.isBefore(checkInDate!.add(const Duration(days: 1)))) {
      debugPrint("Day la id $idString");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ngày trả phải sau ngày nhận ít nhất 1 ngày.")));
      return;
    }
    currentUser = await loadUser(idString!);
    if (currentUser!.fullName == null || currentUser!.phoneNumber == null) {
      showPopup(
          context: context,
          onOkPressed: () async {
            final updatedUser = await Navigator.push<User>(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: currentUser!),
              ),
            );
            // Khi quay lại, nếu có dữ liệu mới, cập nhật UI
            if (updatedUser != null) {
              setState(() {
                debugPrint(
                    "${updatedUser.address}-${updatedUser.fullName}-${updatedUser.phoneNumber}");
                currentUser =
                    updatedUser; // hoặc cập nhật vào controller/state khác
              });
            }
          },
          title: "Thông báo",
          content: "Vui lòng thêm thông tin",
          type: AlertType.warning);
    } else {
      showPopup(
          context: context,
          type: AlertType.info,
          content:
              "Lưu ý bạn có 24h để thanh toán, nếu qua 24h đơn đặt phòng tự động hủy",
          title: "Thông báo quan trọng",
          icon: Icons.close,
          opacity: 1,
          onCancelPressed: () {},
          onOkPressed: () async {
            final randomRooms =
                await fetchRandomRoom(widget.room.roomTypeId, selectedRoom!);
            Random random = Random();
            int idBooking = random.nextInt(99000000) + 1000000;
            final booking = Booking(
                userId: int.parse(idString!),
                bookingId: idBooking,
                checkInDate: checkInDate!.toIso8601String().split('T')[0],
                checkOutDate: checkOutDate!.toIso8601String().split('T')[0],
                totalAmount: price,
                status: 0);
            debugPrint(booking.toString());
            final b = await _service.bookingService.addBooking(booking);
            if (b != null) {
              for (var i in randomRooms) {
                var result = await _service.roomService.holdRoom(i.roomId);
                if (result) {
                  BookingRoom bookingRoom = BookingRoom(
                      bkroomsId: 0,
                      bookingId: booking.bookingId!,
                      roomId: i.roomId,
                      createdAt: DateTime.now());
                  await _service.bookingService.addBookingRoom(bookingRoom);
                } else {
                  debugPrint("Đặt phòng thất bại");
                }
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 2)),
                (route) => false,
              );
            } else {
              debugPrint("Đặt phòng thất bại");
            }
          });

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PaymentScreen(
      //               booking: booking,
      //               rooms: randomRooms,
      //             )));
    }
  }

  Future<User?> loadUser(String id) async {
    try {
      final u = await _service.authService.getUserbyId(id);
      if (u == null) {
        debugPrint("Loi khi lay user ");
      }
      return u;
    } catch (e) {
      debugPrint("Loi khi lay user $e");
    }
  }
}
