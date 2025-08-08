import 'package:booking_app/screens/home/Hotels_Screen.dart';
import 'package:booking_app/widgets/loading.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void onTapCard(BuildContext context, String cityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã chọn $cityName"),duration: Duration(seconds: 1),),
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelScreen(address: cityName),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> destinations = [
      {
        'city': 'Hồ Chí Minh',
        'image': 'https://cdn3.ivivu.com/2023/10/du-lich-sai-gon-ivivu.jpg',
      },
      {
        'city': 'Hà Nội',
        'image': 'https://i1-dulich.vnecdn.net/2022/05/12/Hanoi2-1652338755-3632-1652338809.jpg?w=0&h=0&q=100&dpr=2&fit=crop&s=NxMN93PTvOTnHNryMx3xJw',
      },
      {
        'city': 'Phú Quốc',
        'image': 'https://cdn3.ivivu.com/2023/11/du-lich-phu-quoc-ivivu-4.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ",
            style: TextStyle(fontStyle: FontStyle.normal)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bạn muốn đi đâu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return DestinationCard(
                    cityName: destination['city']!,
                    imageUrl: destination['image']!,
                    onTap: () => onTapCard(context, destination['city']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------ DestinationCard ------------------------

class DestinationCard extends StatelessWidget {
  final String cityName;
  final String imageUrl;
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.cityName,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return const ShimmerLoading.circular(
                      width: double.infinity,
                      height: double.infinity,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    );
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 12,
                child: Text(
                  cityName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
