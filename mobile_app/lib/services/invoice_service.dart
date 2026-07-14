import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/shop_profile_provider.dart';

class InvoiceService {
  static Future<void> generateAndShareInvoice(BuildContext context, Order order) async {
    final shopProfile = context.read<ShopProfileProvider>();
    final shopName = shopProfile.shopName;
    final shopPhone = shopProfile.shopPhone;
    final shopAddress = shopProfile.shopAddress;

    final doc = pw.Document();
    final due = order.price - order.amountPaid;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            if (shopPhone != null && shopPhone.isNotEmpty) pw.Text(shopPhone, style: const pw.TextStyle(fontSize: 10)),
            if (shopAddress != null && shopAddress.isNotEmpty) pw.Text(shopAddress, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text('Order Number: ${order.orderNumber ?? order.id.toString()}'),
            pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
            pw.Divider(height: 24),
            pw.Text('Bill To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Text(order.customerName ?? 'N/A'),
            if (order.customerPhone != null) pw.Text(order.customerPhone!),
            pw.SizedBox(height: 20),
            pw.Text('Order Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 8),
            _row('Clothing Type', order.clothingType),
            _row('Status', order.status),
            _row('Delivery Date', order.deliveryDate?.toString().split(' ')[0] ?? 'N/A'),
            pw.Divider(height: 24),
            _row('Price', 'Rs. ${order.price.toInt()}'),
            _row('Amount Paid', 'Rs. ${order.amountPaid.toInt()}'),
            _row('Amount Due', 'Rs. ${due.toInt()}', bold: true),
            pw.SizedBox(height: 32),
            pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'invoice_${order.id ?? DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static pw.Widget _row(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
