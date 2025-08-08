import 'package:booking_app/data/apiService/AuthService.dart';
import 'package:booking_app/data/apiService/BookingService.dart';
import 'package:booking_app/data/apiService/GoongService.dart';
import 'package:booking_app/data/apiService/HotelImageService.dart';
import 'package:booking_app/data/apiService/HotelsService.dart';
import 'package:booking_app/data/apiService/PaymentService.dart';
import 'package:booking_app/data/apiService/RoomService.dart';

class UnitOfWork {
  static const String apiUrl = "http://10.141.208.115:5000/api/";
  final AuthService authService;
  final HotelsService hotelsService;
  final HotelImageService hotelImageService;
  final RoomService roomService;
  final GoongService goongMapService;
  final BookingService bookingService;
  final PaymentService paymentService;

  UnitOfWork(
      {required this.authService,
      required this.hotelsService,
      required this.hotelImageService,
      required this.roomService,
      required this.goongMapService,
      required this.bookingService,
      required this.paymentService});
}
