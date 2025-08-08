import 'dart:convert';

import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/models/hotels.dart';
import 'package:booking_app/data/models/hotelservice.dart';
import 'package:booking_app/data/models/review.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class HotelsService {
  Future<List<dynamic>> getHotels();

  Future<List<dynamic>> getHotelsbyAddress(String adress);

  Future<List<HotelService>> getServicesByHotelId(String id);

  Future<List<Hotel>> searchHotel(String adress, DateTime? checkinDate,
      DateTime? checkoutDate, int peopleCount);

  Future<List<dynamic>> getReviewsByHotelId(String hotelId);

  Future<bool> addReview(Review rv);

  //Future<List<dynamic>> getHotelById(String id);
  Future<Hotel> getHotelById(int id);
}

class HotelServiceImpl implements HotelsService {
  @override
  Future<Hotel> getHotelById(int id) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Hotel/getHotelbyId/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Da lay duoc khach san: $data");
      return Hotel.fromJson(data);
    } else {
      debugPrint("Loi khi lay khach san: ${response.statusCode}");
      throw Exception('Failed to load hotel: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getReviewsByHotelId(String hotelId) async {
    final url =
        Uri.parse("${UnitOfWork.apiUrl}Review/getAllReviewbyHotelId/$hotelId");
    final response = await http.get(url);
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint(
          "Da lay dc cai riview $data"); // Giả sử response.body là JSON array
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      debugPrint("Loi khi lay danh sach review: ${response.statusCode}");
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }
  }

  @override
  Future<List<Hotel>> getHotels() async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Hotel");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load hotels: ${response.statusCode}");
    }
  }

  @override
  Future<List> getHotelsbyAddress(String adress) async {
    String addressFormat = Uri.encodeComponent(adress);
    final url =
        Uri.parse("${UnitOfWork.apiUrl}Hotel/findHotelbyAddres/$addressFormat");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint("Da lay dc danh sach khach san: $data");
      return data.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load hotels: ${response.statusCode}");
    }
  }

  @override
  Future<List<HotelService>> getServicesByHotelId(String id) async {
    final url = Uri.parse(
        "${UnitOfWork.apiUrl}HotelService/getHotelServicebyHotelId/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint("Da lay dc dich vu: $data");
      return data.map((json) => HotelService.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load services: ${response.statusCode}");
    }
  }

  @override
  Future<List<Hotel>> searchHotel(String adress, DateTime? checkinDate,
      DateTime? checkoutDate, int peopleCount) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Hotel/SreachKS");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json', // ❗ Bắt buộc để server hiểu JSON
          'Accept':
              'application/json', // 👈 Giúp server trả về đúng kiểu dữ liệu
        },
        body: jsonEncode({
          "address": adress,
          "checkIn": checkinDate?.toIso8601String(),
          "checkOut": checkoutDate?.toIso8601String(),
          "peopleCount": peopleCount,
        }));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint("Da lay dc danh sach khach san: $data");
      return data.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to search hotels: ${response.statusCode}");
    }
  }

  @override
  Future<bool> addReview(Review rv) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final url = Uri.parse('${UnitOfWork.apiUrl}Review/addReview');
    final response =await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(rv.toJson()));
      if(response.statusCode==200){
        debugPrint("Them danh gia thanh cong");
        return true;
      }
      else  {
        return false;
      }
  }
}
