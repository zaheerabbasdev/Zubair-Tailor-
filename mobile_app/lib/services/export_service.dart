import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';

class ExportService {
  static Future<void> exportOrdersCsv() async {
    final orders = await OrderRepository().getAll();

    final rows = <List<dynamic>>[
      ['Customer', 'Phone', 'Clothing Type', 'Price', 'Amount Paid', 'Due', 'Status', 'Priority', 'Delivery Date', 'Created At'],
      ...orders.map((o) => [
            o.customerName ?? '',
            o.customerPhone ?? '',
            o.clothingType,
            o.price,
            o.amountPaid,
            o.price - o.amountPaid,
            o.status,
            o.priority ? 'Yes' : 'No',
            o.deliveryDate?.toString().split(' ')[0] ?? '',
            o.createdAt?.toString().split(' ')[0] ?? '',
          ]),
    ];

    await _writeAndShare(rows, 'zubair_tailors_orders');
  }

  static Future<void> exportCustomersCsv() async {
    final customers = await CustomerRepository().getAll();

    final rows = <List<dynamic>>[
      ['Name', 'Phone', 'Address', 'Notes', 'Unique ID'],
      ...customers.map((c) => [
            c.name,
            c.phone,
            c.address ?? '',
            c.notes ?? '',
            c.uniqueId ?? '',
          ]),
    ];

    await _writeAndShare(rows, 'zubair_tailors_customers');
  }

  static Future<void> _writeAndShare(List<List<dynamic>> rows, String baseName) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, '${baseName}_${DateTime.now().millisecondsSinceEpoch}.csv');
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)]);
  }
}
