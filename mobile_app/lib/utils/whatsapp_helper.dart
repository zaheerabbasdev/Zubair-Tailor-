import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String normalizePakistaniPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (!digits.startsWith('92')) {
    digits = '92$digits';
  }
  return digits;
}

Future<void> sendWhatsAppMessage(BuildContext context, {required String phone, required String message}) async {
  final normalized = normalizePakistaniPhone(phone);
  final uri = Uri.parse('https://wa.me/$normalized?text=${Uri.encodeComponent(message)}');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't open WhatsApp")),
    );
  }
}

String buildOrderStatusMessage({
  required String customerName,
  required String clothingType,
  required String status,
  required String shopName,
}) {
  var message = "Hi $customerName, your order for $clothingType at $shopName is now $status.";
  if (status == 'Ready' || status == 'Delivered') {
    message += " Please visit to collect it.";
  }
  return message;
}
