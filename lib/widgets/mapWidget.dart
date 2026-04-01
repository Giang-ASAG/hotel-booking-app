import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HotelMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;

  const HotelMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const API_KEY = "gIiV4j1KXqCxBbeOsCz26wx9F7VaHUCw9FmJU03t";
    const API_KEY12 = "jQNW5c7K2DTo9OJAWs3KetnSuWlHhnvw9o6paTrT";
    final LatLng position = LatLng(latitude, longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vị trí",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "Địa chỉ: $address",
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: position,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.booking_app',
                  tileProvider: NetworkTileProvider(),
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: position,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class EmbeddedMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  final String mapUrl =
      'https://maps.goong.io/maps/embed?mid=fea4c401-e4e7-4967-bc3f-3bedc753296f&lat=21.026745&long=105.801982&z=12';

  EmbeddedMapScreen({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goong Map')),
      body: Center(
        heightFactor: 30,
        widthFactor: 30,
        child: WebViewWidget(controller: WebViewController()..loadRequest(Uri.parse(mapUrl))),
      )
      ,
    );
  }
}

