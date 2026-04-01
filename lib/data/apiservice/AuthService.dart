import 'dart:convert';
import 'package:application_book/data/core/UnitofWork.dart';
import 'package:application_book/data/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthService {
  Future<bool> login(String email, String password);

  Future<bool> register(String email, String password);

  Future<bool> checkEmail(String email);

  Future<bool> sendOTP(String email);

  Future<bool> verifyOTP(String email, String otp);

  Future<User> getUserbyId(String id);

  Future<User> updateUser(User user);

  Future<bool> changePassword(int id, String password, String afterPwd);

  Future<bool> forgetPassword(String email, String password);
}

class AuthServiceImpl implements AuthService {
  @override
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Auth/login");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // ❗ Bắt buộc để server hiểu JSON
      },
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      debugPrint('Token nhận được: $token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      Map<String, dynamic> decodeToken = JwtDecoder.decode(token);
      debugPrint('Token sau khi giai ma nhận được: $decodeToken');
      //final user = User.fromJsonToken(decodeToken);
      final iduser = decodeToken['id'];
      debugPrint('Iduser: $iduser');
      await prefs.setString('iduser', iduser.toString());
      return true;
    } else {
      debugPrint(
        'Đăng nhập thất bại: ${response.statusCode} - ${response.body}',
      );
      return false;
    }
  }

  @override
  Future<bool> register(String email, String password) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Auth/register");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          // ❗ Bắt buộc để server hiểu JSON
          'Accept': 'application/json',
          // 👈 Giúp server trả về đúng kiểu dữ liệu
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }));
    if (response.statusCode == 200) {
      debugPrint(
        'Đăng ky thanh cong: ${response.statusCode} - ${response.body}',
      );
      return true;
    } else {
      debugPrint(
        'Đăng nhập thất bại: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Email đã tồn tại');
    }
  }

  @override
  Future<bool> checkEmail(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse("${UnitOfWork.apiUrl}Auth/check-Email/$encodedEmail");
    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      // ⚠️ Nếu là JSON: {"message": "Email da co ng su dung"}
      final data = jsonDecode(response.body);
      final message = data['message']; // 👈 lấy thông báo từ body
      debugPrint("Lỗi: $message");
      debugPrint("Lỗi: $url");
      return false;
    }
  }

  @override
  Future<bool> sendOTP(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url =
    Uri.parse("${UnitOfWork.apiUrl}Auth/send-otp?email=$encodedEmail");
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print("Gửi OTP thành công");
      return true;
    } else {
      print("Lỗi: ${response.body}");
      return false;
    }
  }

  @override
  Future<bool> verifyOTP(String email, String otp) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Auth/verify-otp");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // ❗ Bắt buộc để server hiểu JSON
        'Accept': 'application/json', // 👈 Giúp server trả về đúng kiểu dữ liệu
      },
      body: jsonEncode({"email": email, "otp": otp}),
    );
    if (response.statusCode == 200) {
      debugPrint('Xác thực OTP thành công: ${response.body}');
      return true;
    } else {
      debugPrint(
        'Xác thực OTP thất bại: ${response.statusCode} - ${response.body}',
      );
      return false;
    }
  }

  @override
  Future<User> getUserbyId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    var url = Uri.parse("${UnitOfWork.apiUrl}User/GetUserbyId/$id");
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("DU lieu user $data");
      return User.fromJson(data);
    } else {
      debugPrint("Loi khi lay du lieu user");
      throw UnimplementedError();
    }
  }

  @override
  Future<User> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    var url = Uri.parse("${UnitOfWork.apiUrl}User/GetUserbyId/${user.userId}");
    var response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(user.toJson()));
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        debugPrint("Cap nhat thanh cong ${data.toString()}");
        return User.fromJson(data);
      } else {
        throw Exception("Phản hồi rỗng từ server.");
      }
    } else {
      debugPrint("Cap nhat that bai user ${response.statusCode} - ${url}");
      throw UnimplementedError();
    }
  }

  @override
  Future<bool> changePassword(int id, String password, String afterPwd) async {
    final url = Uri.parse('${UnitOfWork.apiUrl}Auth/change-password?id=$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "beforePassword": password,
          "afterPassword": afterPwd,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("Cập nhật thành công");
        return true;
      } else {
        debugPrint(
            "Cập nhật thất bại: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
      return false;
    }
  }

  @override
  Future<bool> forgetPassword(String email, String password) async {
    final url = Uri.parse('${UnitOfWork.apiUrl}Auth/forget-password?email=$email');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }, body: '"$password"');
    if (response.statusCode == 200) {
      debugPrint("Thành công!");
      return true;
    } else {
      debugPrint("Thất bại: ${response.statusCode}");
      return false;
    }
  }
}
