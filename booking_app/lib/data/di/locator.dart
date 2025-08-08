import 'package:booking_app/data/apiService/AuthService.dart';
import 'package:booking_app/data/apiService/BookingService.dart';
import 'package:booking_app/data/apiService/GoongService.dart';
import 'package:booking_app/data/apiService/HotelImageService.dart';
import 'package:booking_app/data/apiService/HotelsService.dart';
import 'package:booking_app/data/apiService/PaymentService.dart';
import 'package:booking_app/data/apiService/RoomService.dart';
import 'package:get_it/get_it.dart';

import '../core/UnitOfWork.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Đăng ký các dịch vụ là singleton
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<HotelsService>(() => HotelServiceImpl());
  getIt.registerLazySingleton<HotelImageService>(() => HotelImageServiceImpl());
  getIt.registerLazySingleton<RoomService>(() => RoomServiceImpl());
  getIt.registerLazySingleton<GoongService>(() => GoongService());
  getIt.registerLazySingleton<BookingService>(() => BookingServiceImpl());
  getIt.registerLazySingleton<PaymentService>(() => PaymentServiceImpl());

  // Đăng ký UnitOfWork với tất cả các dịch vụ
  getIt.registerLazySingleton<UnitOfWork>(() => UnitOfWork(
        authService: getIt<AuthService>(),
        hotelsService: getIt<HotelsService>(),
        hotelImageService: getIt<HotelImageService>(),
        roomService: getIt<RoomService>(),
        goongMapService: getIt<GoongService>(),
        bookingService: getIt<BookingService>(),
        paymentService: getIt<PaymentService>(),
      ));
}
