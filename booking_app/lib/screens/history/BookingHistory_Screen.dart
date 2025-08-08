import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/booking.dart';
import 'package:booking_app/data/models/bookingroom.dart';
import 'package:booking_app/data/models/hotels.dart';
import 'package:booking_app/data/models/review.dart';
import 'package:booking_app/data/models/roomtype.dart';
import 'package:booking_app/screens/main/Main_Screen.dart';
import 'package:booking_app/screens/payment/Payment_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<BookingMVVM> bookings = [];
  final _service = getIt<UnitOfWork>();

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final result = await _service.bookingService.getAllBooking();
      setState(() => bookings = result ?? []);
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Số lượng tab
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Quản lý đặt phòng'),
          backgroundColor: Colors.blue,
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Chưa thanh toán'),
              Tab(text: 'Đã thanh toán'),
              Tab(text: 'Đã nhận'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingListByStatus(0),
            _buildBookingListByStatus(1),
            _buildBookingListByStatus(3),
            _buildBookingListByStatus(2),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingListByStatus(int status) {
    final filtered = bookings.where((b) => b.status == status).toList();
    if (filtered.isEmpty) {
      return const Center(
          child: Text('Không có dữ liệu', style: TextStyle(fontSize: 18)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => FutureBuilder<Map<String, dynamic>>(
        future: _fetchBookingDetails(filtered[index]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Text('Lỗi khi tải thông tin đặt phòng');
          }
          return BookingCard(
            booking: filtered[index],
            hotel: snapshot.data!['hotel'] as Hotel,
            roomType: snapshot.data!['roomType'] as RoomType,
            bookingRoom: snapshot.data!['bookingRooms'],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchBookingDetails(BookingMVVM booking) async {
    final hotel = await _service.hotelsService.getHotelById(booking.hotelId!);
    final roomTypes =
    await _service.roomService.getRoomsByHotelId(booking.hotelId!);
    final bookingRooms = await _service.bookingService
        .getBookingRoom(booking.bookingId!) as List<BookingRoom>;
    final roomType = (roomTypes as List<RoomType>).firstWhere(
          (r) => r.roomTypeId == booking.roomTypeId,
      orElse: () => RoomType(
        roomTypeId: -1,
        images: null,
        typeName: 'Unknown',
        price: 0,
        capacity: 0,
        count: 0,
      ),
    );
    return {
      'hotel': hotel,
      'roomType': roomType,
      'bookingRooms': bookingRooms
    };
  }
}


class BookingCard extends StatelessWidget {
  final BookingMVVM booking;
  final Hotel hotel;
  final RoomType roomType;
  final List<BookingRoom> bookingRoom;

  const BookingCard(
      {super.key,
      required this.booking,
      required this.hotel,
      required this.roomType,
      required this.bookingRoom});

  @override
  Widget build(BuildContext context) {
    final _service = getIt<UnitOfWork>();
    return InkWell(
      onTap: () {
        debugPrint("Test nhấn");
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã đặt phòng: ${booking.bookingId}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(hotel.hotelName),
            Text(roomType.typeName),
            Text('Ngày nhận: ${booking.checkInDate.substring(0, 10)}'),
            Text('Ngày trả: ${booking.checkOutDate.substring(0, 10)}'),
            Text('Số lượng phòng: ${bookingRoom.length}'),
            Text('${booking.totalAmount.toStringAsFixed(0)} VND',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500)),
            // Text(booking.status! ? 'Đã thanh toán' : 'Chưa thanh toán',
            //     style: const TextStyle(
            //         color: Colors.green, fontWeight: FontWeight.w500)),
            if (booking.status==3) ...[
              Text('Đã nhận',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Đánh giá",
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReviewScreen(hotel: hotel))),
                    ),
                  ),
                ],
              ),
            ] else if (booking.status==0)...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Hủy đặt phòng",
                      onPressed: () {
                        showPopup(
                          context: context,
                          title: 'Thông báo',
                          content: 'Ban có chắc là muốn hủy không?',
                          onOkPressed: () async {
                            try {
                              await _service.bookingService
                                  .updateStatus(booking.bookingId!, 2);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Bạn đã hủy phòng thành công"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MainScreen(
                                        currentIndex:
                                            2)), // Hoặc màn hình bạn muốn
                              );
                              debugPrint('Cancel thành công');
                            } catch (e) {
                              debugPrint('Bi loi gi do $e');
                            }
                          },
                          type: AlertType.info,
                          onCancelPressed: () {},
                        );
                      },
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: "Thanh toán",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    PaymentScreen(booking: booking)));
                      },
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ]
              //1 = Da thanh toan
            else if(booking.status==1)...[
                Text('Đã thanh toán',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w500)),
              ]
                // Huy
            else ...[
                  Text('Đã hủy',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500)),
                ]
          ],
        ),
      ),
    );
  }
}

class ReviewScreen extends StatefulWidget {
  final Hotel hotel;

  const ReviewScreen({super.key, required this.hotel});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final _service = getIt<UnitOfWork>();
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Đánh giá"),
          backgroundColor: Colors.blue,
          centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(widget.hotel.hotelName,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _buildTextField(),
            const SizedBox(height: 20),
            _buildStarRating(),
            const SizedBox(height: 30),
            CustomButton(text: "Lưu", onPressed: _submitReview),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: _reviewController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "Đánh giá",
          hintText: "Chi tiết đánh giá",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          5,
          (index) => IconButton(
                icon: Icon(index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber, size: 32),
                onPressed: () => setState(() => _rating = index + 1),
              )),
    );
  }

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString('iduser') ?? '0');
    final review = Review(
      ReviewId: 0,
      HotelId: widget.hotel.hotelId,
      UserId: userId,
      StarRating: _rating,
      Description: _reviewController.text,
      UserName: 'string',
    );
    final result = await _service.hotelsService.addReview(review);
    if (result) {
      showPopup(
        context: context,
        onOkPressed: () => Navigator.pop(context),
        title: 'Thông báo',
        content: 'Đánh giá thành công',
        type: AlertType.success,
      );
    } else {
      debugPrint("Failed to add review");
    }
  }
}
