import 'dart:convert';

import 'package:application_book/data/core/UnitofWork.dart';
import 'package:application_book/data/models/booking.dart';
import 'package:application_book/data/models/bookingroom.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class BookingService {
  Future<Booking> addBooking(Booking book);

  Future<List<BookingMVVM>> getAllBooking();


  Future<List<dynamic>> getBookingRoom(int id);

  Future<BookingRoom> addBookingRoom(BookingRoom book);

  Future<void> cancelBooking(int id);

  Future<bool> updateStatus(int id,int num);
}

class BookingServiceImpl implements BookingService {
  @override
  Future<Booking> addBooking(Booking book) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Booking");

    // Validate booking data before sending
    if (book.bookingId == null ||
        book.userId == null ||
        book.totalAmount <= 0) {
      debugPrint("Invalid booking data: ${book.toJson()}");
      throw Exception('Invalid booking data provided');
    }
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Booking added successfully: $data");
        return Booking.fromJson(data);
      } else {
        // Log detailed error information
        debugPrint(
            "Failed to add booking: Status ${response.statusCode}, Body: ${response.body}");
        throw Exception(
            'Failed to add booking: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint("Error in addBooking: $e");
      throw Exception('Error adding booking: $e');
    }
  }

  @override
  Future<BookingRoom> addBookingRoom(BookingRoom book) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Booking/addBookingRoom");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          // ❗ Bắt buộc để server hiểu JSON
          'Accept': 'application/json',
          // 👈 Giúp server trả về đúng kiểu dữ liệu
        },
        body: jsonEncode(book.toJson()));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Da them duoc bookingroom $data");
      return BookingRoom.fromJson(data);
    } else {
      debugPrint("Loi khi them bookingRoom: ${response.statusCode}");
      throw Exception('Loi khi them bookingRoom ${response.statusCode}');
    }
  }


  @override
  Future<List<BookingMVVM>> getAllBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final id = prefs.getString('iduser');
    final url = Uri.parse("${UnitOfWork.apiUrl}Booking/getAllbyUser/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint("Da lay dc du lieu{$data.toString()}");
      return data.map((json) => BookingMVVM.fromJson(json)).toList();
    } else {
      debugPrint("Loi khi lay du lieu");
      return [];
    }
  }

  @override
  Future<List> getBookingRoom(int id) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Booking/getBookingRoom/$id");
    final respose = await http.get(url);
    if (respose.statusCode == 200) {
      final List<dynamic> data = jsonDecode(respose.body);
      debugPrint("Da lay dc du lieu{$data.toString()}");
      return data.map((e) => BookingRoom.fromJson(e)).toList();
    } else {
      debugPrint("Loi khi lay du lieu");
      return [];
    }
  }

  @override
  Future<void> cancelBooking(int id) async {
    final url = Uri.parse('${UnitOfWork.apiUrl}Booking/cancelBooking/$id');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      debugPrint("Huy thanh cong");
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<bool> updateStatus(int id,int num) async {
    final url = Uri.parse('${UnitOfWork.apiUrl}Booking/updateStatus?id=$id&num=$num');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      debugPrint("Cap nhat thanh cong123");
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}