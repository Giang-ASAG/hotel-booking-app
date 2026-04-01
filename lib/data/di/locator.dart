import 'package:application_book/data/apiservice/AuthService.dart';
import 'package:application_book/data/apiservice/BookingService.dart';
import 'package:application_book/data/apiservice/GoongService.dart';
import 'package:application_book/data/apiservice/HotelImageService.dart';
import 'package:application_book/data/apiservice/HotelsService.dart';
import 'package:application_book/data/apiservice/PaymentService.dart';
import 'package:application_book/data/apiservice/RoomService.dart';
import 'package:application_book/data/core/UnitofWork.dart';
import 'package:get_it/get_it.dart';

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