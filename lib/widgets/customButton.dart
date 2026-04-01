import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> showPopup({
  required BuildContext context,
  String? title,
  String? content,
  AlertType? type,
  required VoidCallback onOkPressed,
  VoidCallback? onCancelPressed, IconData? icon, double? opacity
}) async {
  Alert(
    context: context,
    type: type ?? AlertType.info,
    onWillPopActive: true,
    closeIcon: Opacity(
      opacity: opacity ?? 0.5,
      child: Icon(icon),
    ),
    // ✅ Nếu muốn chặn nút back thì set false
    content: Column(
      children: [
        const SizedBox(height: 16), // 👈 Giãn cách giữa icon và title
        if (title != null)
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 10),
        if (content != null)
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
      ],
    ),
    buttons: [
      if (onCancelPressed != null)
        DialogButton(
          child: const Text("Huỷ", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
            onCancelPressed();
          },
          color: Colors.grey,
        ),
      DialogButton(
        child: const Text("OK", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pop(context);
          onOkPressed();
        },
        color: Colors.green,
      ),
    ],
  ).show();
}
