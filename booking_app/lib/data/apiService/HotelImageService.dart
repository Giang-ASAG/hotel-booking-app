import 'dart:convert';

import 'package:booking_app/data/models/hotelImage.dart';
import 'package:http/http.dart' as http;
abstract class HotelImageService {
  Future<List<dynamic>> getHotelImages(String hotelId);
}

class HotelImageServiceImpl implements HotelImageService{
  @override
  Future<List<HotelImage>> getHotelImages(String hotelId) async {
    var url = Uri.parse("HotelImage/getImagebyIdHotel/$hotelId");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // Assuming the response body is a JSON array of hotel images
      final List<dynamic> data = jsonDecode(response.body);
      return  data.map((json) => HotelImage.fromJson(json)).toList();// Adjust this based on your actual data structure
    } else {
      throw Exception("Failed to load hotel images: ${response.statusCode}");
    }
    // TODO: implement getHotelImages
  }

}