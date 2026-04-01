import 'package:application_book/data/apiservice/AuthService.dart';
import 'package:application_book/data/apiservice/BookingService.dart';
import 'package:application_book/data/apiservice/GoongService.dart';
import 'package:application_book/data/apiservice/HotelImageService.dart';
import 'package:application_book/data/apiservice/HotelsService.dart';
import 'package:application_book/data/apiservice/PaymentService.dart';
import 'package:application_book/data/apiservice/RoomService.dart';

class UnitOfWork {
  static const String apiUrl = "http://apibookinghotel.runasp.net/api/";
  //static const String apiUrl = "http://192.168.1.10:5000/api/";
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