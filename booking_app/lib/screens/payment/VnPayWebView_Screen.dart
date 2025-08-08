import 'package:booking_app/data/models/vnpayresponse.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VnPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const VnPayWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<VnPayWebViewScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<VnPayWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            if (uri.path.contains("/api/Payment/payment-return")) {
              final responseCode = uri.queryParameters['vnp_ResponseCode'];
              if (responseCode == '00') {
                final txnRef = uri.queryParameters['vnp_TxnRef'];
                final amount = uri.queryParameters['vnp_Amount'];
                final BankCode = uri.queryParameters['vnp_BankCode'];
                final vnp_OrderInfo = uri.queryParameters['vnp_OrderInfo'];
                final vnp_PayDate = uri.queryParameters['vnp_PayDate'];
                debugPrint(
                    '--------------------------------${responseCode.toString()}----------------');
                final isSuccess = responseCode == '00';
                final result = VNPayResponse(
                    vnp_ResponseCode: responseCode!,
                    vnp_TxnRef: txnRef!,
                    vnp_Amount: amount!,
                    vnp_BankCode: BankCode!,
                    vnp_OrderInfo: vnp_OrderInfo!,
                    vnp_PayDate: vnp_PayDate!);
                Navigator.pop(context, {"response": result});

                return NavigationDecision.prevent;
              }
              else{
                Navigator.pop(context);
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VNPAY'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
