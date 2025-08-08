import 'dart:async';

import 'package:booking_app/data/apiService/PaymentService.dart';
import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/booking.dart';
import 'package:booking_app/data/models/bookingroom.dart';
import 'package:booking_app/data/models/momoresponse.dart';
import 'package:booking_app/data/models/payment.dart';
import 'package:booking_app/data/models/room.dart';
import 'package:booking_app/data/models/vnpayresponse.dart';
import 'package:booking_app/screens/history/BookingHistory_Screen.dart';
import 'package:booking_app/screens/home/Home_Screen.dart';
import 'package:booking_app/screens/main/Main_Screen.dart';
import 'package:booking_app/screens/payment/VnPayWebView_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PaymentScreen extends StatefulWidget {
  // final List<Room> rooms;
  final BookingMVVM booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  //late Timer _timer;
  //int _start = 600;
  final _payservice = PaymentServiceImpl();
  final _service = getIt<UnitOfWork>();
  final List<String> _paymentMethods = [
    "VNPay",
    // "ZaloPay",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // holdRoom();
    // _startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //_timer.cancel();
    super.dispose();
  }

  // Future<void> holdRoom() async {
  //   try {
  //     for (var i in widget.rooms) {
  //       final result = await _service.roomService.holdRoom(i.roomId);
  //       if (result) {
  //         debugPrint("Giu phong thanh cong ${i.roomNumber}");
  //       } else {
  //         debugPrint("Giu phong that bai ${i.roomNumber}");
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Loi holdRoom $e");
  //   }
  // }

  // Future<void> unholdRoom() async {
  //   try {
  //     for (var i in widget.rooms) {
  //       final result = await _service.roomService.unholdRoom(i.roomId);
  //       if (result) {
  //         debugPrint("Huy giu phong thanh cong ${i.roomNumber}");
  //       } else {
  //         debugPrint("Huy giu phong that bai ${i.roomNumber}");
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Loi holdRoom $e");
  //   }
  // }

  // void _startTimer() {
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (_start > 0) {
  //       setState(() {
  //         _start--;
  //       });
  //     } else {
  //       _timer.cancel();
  //       unholdRoom();
  //       showPopup(
  //           context: context,
  //           title: "Thông báo",
  //           content: "Hết thời gian giữ phòng",
  //           icon: Icons.circle,
  //           opacity: 0,
  //           type: AlertType.warning,
  //           onOkPressed: () {
  //             Navigator.of(context).pushAndRemoveUntil(
  //               MaterialPageRoute(builder: (_) => HomeScreen()),
  //               (Route<dynamic> route) => false,
  //             );
  //           });
  //     }
  //   });
  // }

  // String get timerString {
  //   Duration duration = Duration(seconds: _start);
  //   return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(8, 0, 8, 25), // 👈 padding dưới: 24
        child: CustomButton(
          text: "Thanh toán",
          onPressed: () => btnPayment(context),
        ),
      ),
    );
  }

  Future<MomoResponse?> fetchPayment(int amount) async {
    try {
      var result = await _payservice.payment(amount);
      if (result != null) {
        debugPrint(result.toString());
        return result; // Trả về kết quả nếu không null
      } else {
        return null; // Trả về null nếu không có kết quả
      }
    } catch (e) {
      debugPrint('Lỗi: $e');
      return null; // Trả về null khi có lỗi
    }
  }

  void btnPayment(BuildContext context) {
    createPayment(context);
    if (_selectedMethod == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("VNPay")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zalo")),
      );
    }
  }

  Future<void> createPayment(BuildContext context) async {
    String amount = widget.booking.totalAmount.toStringAsFixed(0);
    final result = await _payservice.createPayment(amount);
    if (result != "") {
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnPayWebViewScreen(paymentUrl: result),
        ),
      );
      if (paymentResult != null) {
        late VNPayResponse vnPayResponse;
        setState(() {
          vnPayResponse = paymentResult["response"] as VNPayResponse;
        });
        showPopup(
            context: context,
            onOkPressed: () async {
              // debugPrint(vnPayResponse.toString());
              // final book = Booking(
              //     bookingId: int.parse(vnPayResponse.vnp_TxnRef),
              //     userId: widget.booking.userId,
              //     status: widget.booking.status,
              //     checkInDate: widget.booking.checkInDate,
              //     checkOutDate: widget.booking.checkOutDate,
              //     totalAmount: widget.booking.totalAmount);
              // debugPrint(book.toString());
              // final b = await _service.bookingService.addBooking(book);
              if (widget.booking != null) {
                final pay = Payment(
                    paymentId: int.parse(vnPayResponse.vnp_TxnRef) ,
                    bookingId: widget.booking.bookingId!,
                    note: vnPayResponse.vnp_OrderInfo,
                    paymentMethod: vnPayResponse.vnp_BankCode,
                    paymentDate: DateTime.now(),
                    totalAmount: widget.booking.totalAmount);

                try {
                  var result = await _service.bookingService
                      .updateStatus(widget.booking.bookingId!,1);
                  if (result) {
                    debugPrint("Cap nhat thanh cong");
                    addPayment(pay);
                  } else {
                    debugPrint("Cap nhat that bai");
                  }
                } catch (e) {
                  debugPrint("Loi cap nhat thanh toan");
                }
                // for (var i in widget.rooms) {
                //   final b = BookingRoom(
                //       bkroomsId: 0,
                //       bookingId: book.bookingId!,
                //       roomId: i.roomId);
                //   addBookingRoom(b);
                // }
                //holdRoom();
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (_) => BookingHistoryScreen()));
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreen(currentIndex: 2)),
                    (route) => false,);
              } else {
                debugPrint("Loi dat phong roi");
              }
            },
            content: "Thanh toán thành công",
            title: "Thông báo",
            type: AlertType.success);
      } else {
        showPopup(
            context: context,
            onOkPressed: () {},
            content: "Đã thoát thanh toán",
            title: "Thông báo",
            type: AlertType.info);
      }
    }
  }

  Future<void> addBookingRoom(BookingRoom b) async {
    try {
      final result = await _service.bookingService.addBookingRoom(b);
      if (result != null) {
        debugPrint("Them thanh cong addBookingRoom");
      } else {
        debugPrint("Them that bai BookingRoom");
      }
    } catch (e) {
      debugPrint("Loi them payment $e");
    }
  }

  Future<void> addPayment(Payment p) async {
    try {
      final result = await _payservice.addPayment(p);
      if (result) {
        debugPrint("Them thanh cong payment");
      } else {
        debugPrint("Them that bai");
      }
    } catch (e) {
      debugPrint("Loi them payment $e");
    }
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Text(
          //   "Thời gian giữ phòng $timerString",
          //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 20),
          Text(
            "Chọn phương thức thanh toán ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildPaymentMethodsList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: List.generate(
        _paymentMethods.length,
        (index) => _buildPaymentMethodItem(index),
      ),
    );
  }

  Widget _buildPaymentMethodItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<int>(
        value: index,
        groupValue: _selectedMethod,
        activeColor: Colors.blue,
        title: Text(_paymentMethods[index]),
        onChanged: (value) {
          setState(() {
            _selectedMethod = value!;
          });
        },
      ),
    );
  }
}
