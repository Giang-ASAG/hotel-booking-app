import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/hotels.dart';
import 'package:booking_app/data/models/hotelservice.dart';
import 'package:booking_app/data/models/review.dart';
import 'package:booking_app/screens/home/Room_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/imagepage.dart';
import 'package:booking_app/widgets/loading.dart';
import 'package:booking_app/widgets/mapWidget.dart';
import 'package:flutter/material.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;

  const HotelDetailScreen(
      {super.key, required this.hotel, this.checkinDate, this.checkoutDate});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _service = getIt<UnitOfWork>();
  late List<HotelService> services = [];
  late List<Review> reviews = [];

  Future<void> fetchHotelService() async {
    String id = widget.hotel.hotelId.toString();
    try {
      final result = await _service.hotelsService.getServicesByHotelId(id);
      if (result.isNotEmpty) {
        setState(() {
          services.addAll(result);
        });
      } else {
        debugPrint("Không có dịch vụ nào");
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy dịch vụ: $e");
    }
  }

  @override
  void initState() {
    fetchHotelService();
    fetchReview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(8, 0, 8, 20), //padding dưới: 24
        child: CustomButton(
          text: "Xem phòng",
          onPressed: () => btnSeeRoom(context),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('Chi tiết khách sạn'),
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
          buildHotelInfo(),
          const SizedBox(height: 16),
          buildServices(),
          const SizedBox(height: 16),
          // EmbeddedMapScreen(
          //     latitude: widget.hotel.xCoordinate!,
          //     longitude: widget.hotel.yCoordinate!),
          HotelMapWidget(
            latitude: widget.hotel.xCoordinate!,
            longitude: widget.hotel.yCoordinate!,
            address: widget.hotel.address!,
          ),
          const SizedBox(height: 16),
          buildReviewSection(),
        ],
      ),
    );
  }

  Future<void> btnSeeRoom(BuildContext context) async {
    if (widget.checkinDate == null || widget.checkoutDate == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RoomScreen(hotelId: widget.hotel.hotelId)));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RoomScreen(
                    hotelId: widget.hotel.hotelId,
                    checkinDate: widget.checkinDate,
                    checkoutDate: widget.checkoutDate,
                  )));
    }
  }

  Widget buildImagePlaceholder() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: widget.hotel.imagePaths != null &&
            widget.hotel.imagePaths!.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PageView.builder(
            itemCount: widget.hotel.imagePaths!.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.hotel.imagePaths![index];
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


  Widget buildHotelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hotel.hotelName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(widget.hotel.phoneNumber ?? "Số điện thoại không có sẵn"),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.email, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(widget.hotel.email ?? "Email không có sẵn"),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '★' * widget.hotel.star!.toInt(),
              style: const TextStyle(color: Colors.yellow, fontSize: 25),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          "Mô tả",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 1, right: 5),
          child: Text(
            widget.hotel.description ?? "",
            style: const TextStyle(fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget buildServices() {
    if (services.isEmpty) {
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
          children: services.map((s) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(s.serviceName, style: const TextStyle(fontSize: 14)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> fetchReview() async {
    try {
      final result = await _service.hotelsService
          .getReviewsByHotelId(widget.hotel.hotelId.toString());
      if (result.isNotEmpty) {
        setState(() {
          reviews = result as List<Review>;
        });
      } else {
        debugPrint("Không có đánh giá nào");
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy đánh giá: $e");
      debugPrint(reviews.toString());
    }
  }

  Widget buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Đánh giá",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (reviews.isEmpty) ...[
          Text("Không có đánh giá nào",
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ] else ...[
          for (var i in reviews) ...[
            const SizedBox(height: 8),
            buildReviewTile(i.UserName, i.StarRating, i.Description),
          ]
        ]
      ],
    );
  }

  Widget buildReviewTile(String user, int rating, String comment) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.account_circle, color: Colors.black54, size: 40),
      ),
      title: Text(user),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              ),
            ),
          ),
          Text(comment),
        ],
      ),
    );
  }
}




