import 'dart:convert';

import 'package:application_book/data/core/UnitofWork.dart';
import 'package:application_book/data/models/payment.dart';
import 'package:application_book/data/models/vnpayresponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class PaymentService {
  Future<bool> addPayment(Payment pay);
  Future<String> createPayment(String amountText);
  VNPayResponse? processPaymentReturn(Uri uri);
}

class PaymentServiceImpl implements PaymentService {

  @override
  Future<String> createPayment(String amountText) async {
    try {
      final url = Uri.parse("${UnitOfWork.apiUrl}Payment/create-order");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": int.parse(amountText)}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data["payment_url"];
        debugPrint("Lay link $url");
        return url;
      } else {
        debugPrint("Lay link that bai");
        return "";
      }
    } catch (e) {
      debugPrint("Loi ket noi $e");
      return "";
    }
  }
  @override
  VNPayResponse? processPaymentReturn(Uri uri) {
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    final txnRef = uri.queryParameters['vnp_TxnRef'];
    final amount = uri.queryParameters['vnp_Amount'];
    final bankCode = uri.queryParameters['vnp_BankCode'];
    final orderInfo = uri.queryParameters['vnp_OrderInfo'];
    final payDate = uri.queryParameters['vnp_PayDate'];

    if (responseCode != null &&
        txnRef != null &&
        amount != null &&
        bankCode != null &&
        orderInfo != null &&
        payDate != null) {
      DateTime date = DateTime.parse(payDate.substring(8));
      return VNPayResponse(
        vnp_ResponseCode: responseCode,
        vnp_TxnRef: txnRef,
        vnp_Amount: amount,
        vnp_BankCode: bankCode,
        vnp_OrderInfo: orderInfo,
        vnp_PayDate: date.toString(),
      );
    }
    return null;
  }

  @override
  Future<bool> addPayment(Payment pay) async {
    final url = Uri.parse("${UnitOfWork.apiUrl}Payment/addPayment");
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }, body: jsonEncode(pay.toJson()));
    if(response.statusCode==200){
      debugPrint(response.body);
      return true;
    }
    else{
      debugPrint("Loi khi them payment");
      return false;
    }
  }
}