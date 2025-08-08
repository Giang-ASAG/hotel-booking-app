import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/hotels.dart';
import 'package:booking_app/screens/detail/HotelDetail_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/loading.dart';
import 'package:flutter/material.dart';

class HotelScreen extends StatefulWidget {
  final String address;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;
  final int? peoplecount;

  const HotelScreen(
      {super.key,
      required this.address,
      this.checkinDate,
      this.checkoutDate,
      this.peoplecount});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  int? selectedStarRating;
  late List<Hotel> hotels = [];
  bool isLoading = true;
  final _service = getIt<UnitOfWork>();

  @override
  void initState() {
    fetchHotels();
    super.initState();
  }

  @override
  void dispose() {
    // Nếu có controller hoặc stream, dispose ở đây
    super.dispose();
  }

  Future<void> fetchHotels() async {
    if (widget.checkinDate != null) {
      try {
        final result = await _service.hotelsService.searchHotel(widget.address,
            widget.checkinDate, widget.checkoutDate, widget.peoplecount!);
        setState(() {
          debugPrint("Danh sach khach san da co check in check out");
          hotels = result;
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Lỗi khi lấy danh sách khách sạn: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải danh sách khách sạn: $e")),
        );
      }
    } else {
      try {
        final result =
            await _service.hotelsService.getHotelsbyAddress(widget.address);
        setState(() {
          debugPrint("Danh sach khach san k co check in check out");
          hotels = result as List<Hotel>;
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Lỗi khi lấy danh sách khách sạn: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải danh sách khách sạn: $e")),
        );
      }
    }
  }

  void sortbyStar() {
    fetchHotels();
    setState(() {
      isLoading = true; // Bắt đầu loading
    });

    Future.delayed(const Duration(seconds: 1), () {
      final filteredHotels = hotels
          .where((hotel) =>
              hotel.star!.toStringAsFixed(0) == selectedStarRating.toString())
          .toList();
      setState(() {
        hotels.clear();
        hotels.addAll(filteredHotels);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh sách khách sạn",
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.checkinDate == null ||
                      widget.checkoutDate == null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade100,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedStarRating,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(10),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                icon: const Icon(Icons.arrow_drop_down),
                                items: List.generate(5, (index) {
                                  final stars = '★' * (index + 1);
                                  return DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text('$stars'),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStarRating = value!;
                                    debugPrint(value.toString());
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
// Khoảng cách giữa Dropdown và nút
                        CustomButton(
                          text: "Xác nhận",
                          onPressed: () {
                            setState(() {
                              sortbyStar();
                            });
                          },
                          width: 120,
                        )
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  TitleSection(address: widget.address),
                  const SizedBox(height: 16),
                  Expanded(
                    child: HotelList(
                      hotels: hotels,
                      checkinDate: widget.checkinDate,
                      checkoutDate: widget.checkoutDate,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  final String address;

  const TitleSection({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        address,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HotelList extends StatelessWidget {
  final List<Hotel> hotels;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;

  const HotelList(
      {super.key, required this.hotels, this.checkinDate, this.checkoutDate});

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) {
      return const Center(
        child: Text(
          "Không có khách sạn nào phù hợp",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      itemCount: hotels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return HotelCard(
          hotel: hotels[index],
          onTap: () {
            onTapCard(context, hotels[index]);
          },
        );
      },
    );
  }

  Future<void> onTapCard(BuildContext context, Hotel hotel) async {
    if (checkinDate != null && checkoutDate != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HotelDetailScreen(
                    hotel: hotel,
                    checkinDate: checkinDate,
                    checkoutDate: checkoutDate,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HotelDetailScreen(hotel: hotel)));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Bạn đã chọn: ${hotel.hotelName}"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback? onTap;

  const HotelCard({
    super.key,
    required this.hotel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                hotel.imagePaths != null && hotel.imagePaths!.isNotEmpty
                    ? hotel.imagePaths!.first
                    : 'https://tripi.vn/blog/vi/doi-song/nhung-hinh-anh-may-man-dep-nhat-tripi',
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return ShimmerLoading.rectangular(
                        height: 140,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ));
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey,
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
            ),

            // Tên khách sạn
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                hotel.hotelName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Địa chỉ + SĐT (có icon)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hotel.address!,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        hotel.phoneNumber!,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        hotel.star!.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
