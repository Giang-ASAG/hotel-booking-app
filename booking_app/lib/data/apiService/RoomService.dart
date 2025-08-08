import 'dart:convert';

import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/models/room.dart';
import 'package:booking_app/data/models/roomservice.dart';
import 'package:booking_app/data/models/roomtype.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class RoomService {
  Future<List<dynamic>> getRoomsByHotelId(int hotelId);

  Future<List<dynamic>> getRoomServiceByIdRoom(int roomId);

  Future<List<dynamic>> getRandomRoom(int id, int count);

  Future<RoomType?> getRoomTypebyId(int id);

  Future<bool> holdRoom(int id);

  Future<bool> unholdRoom(int id);

  Future<List> getRoomTypeBySearch(
      int hotel, DateTime checkin, DateTime checkout);
}

class RoomServiceImpl implements RoomService {
  @override
  Future<List<dynamic>> getRoomsByHotelId(int hotelId) async {
    final url = Uri.parse(
        "${UnitOfWork.apiUrl}RoomType/getAllRoomTypeAndCount/$hotelId");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RoomType.fromJson(json)).toList();
    } else {
      debugPrint("Lỗi khi lấy danh sách phòng: ${response.statusCode}");
      throw Exception('Failed to load rooms: ${response.statusCode}');
    }
  }

  @override
  Future<List> getRoomServiceByIdRoom(int roomId) async {
    final url = Uri.parse(
        "${UnitOfWork.apiUrl}RoomService/getAllbyRoomTypeId?id=$roomId");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RoomServices.fromJson(json)).toList();
    } else {
      debugPrint("Lỗi khi lấy dich vu phongf: ${response.statusCode}");
      throw Exception('Failed to load rooms: ${response.statusCode}');
    }
  }

  @override
  Future<List> getRandomRoom(int id, int count) async {
    final url =
        Uri.parse("${UnitOfWork.apiUrl}Room/RandomRoom?id=$id&count=$count");
    final respose = await http.get(url);
    if (respose.statusCode == 200) {
      final List<dynamic> data = jsonDecode(respose.body);
      debugPrint("Danh sách phòng ngẫu nhiên: $data");
      return data.map((json) => Room.fromJson(json)).toList();
    } else {
      debugPrint(
          "Lỗi khi lấy danh sách phòng ngẫu nhiên: ${respose.statusCode}");
      throw Exception('Failed to load random rooms: ${respose.statusCode}');
    }
  }

  @override
  Future<bool> holdRoom(int id) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Room/holdRoom/$id");
    final response = await http.put(url);
    if (response.statusCode == 200) {
      debugPrint("Giu phong thanh cong");
      return true;
    } else {
      debugPrint("Giu phong that bai");
      return false;
    }
  }

  @override
  Future<bool> unholdRoom(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse("${UnitOfWork.apiUrl}Room/updateStatus/$id");
    final token = prefs.getString("token");
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      debugPrint("huy giu phong thanh cong");
      return true;
    } else {
      debugPrint("huy giu that bai");
      return false;
    }
  }

  @override
  Future<RoomType> getRoomTypebyId(int id) async {
    try {
      final url = Uri.parse('${UnitOfWork.apiUrl}RoomType/getRoomTypebyId/$id');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(data);
        return RoomType.fromJson(data);
      } else {
        debugPrint('Failed to load room type: ${response.statusCode}');
        throw Exception('Failed to load hotel');
      }
    } catch (e) {
      debugPrint("Loi khi lay roomType: ${e}");
      throw Exception('Failed to load hotel: ${e}');
    }
  }

  @override
  Future<List> getRoomTypeBySearch(
      int hotel, DateTime checkin, DateTime checkout) async {
    final url = Uri.parse(
        '${UnitOfWork.apiUrl}RoomType/getAllRoomTypeAndCountbySreach');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "hotelId": hotel,
          "checkIn": checkin.toIso8601String(),
          "checkOut": checkout.toIso8601String()
        }));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint(data.toString());
      return data.map((json) => RoomType.fromJson(json)).toList();
    } else {
      debugPrint('Failed to load room type: ${response.statusCode}');
      throw Exception('Failed to load room type: ${response.statusCode}');
    }
  }
}
