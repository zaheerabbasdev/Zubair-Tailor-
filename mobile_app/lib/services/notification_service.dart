import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/order.dart';
import '../repositories/order_repository.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidSettings));

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDeliveryReminder(Order order) async {
    if (order.id == null || order.deliveryDate == null || order.status == 'Delivered') {
      return;
    }

    final d = order.deliveryDate!.subtract(const Duration(days: 1));
    final scheduled = DateTime(d.year, d.month, d.day, 9, 0);
    if (scheduled.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      order.id!,
      "Delivery Due Tomorrow",
      "${order.customerName ?? 'Customer'} — ${order.clothingType} is due for delivery tomorrow.",
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'delivery_reminders',
          'Delivery Reminders',
          channelDescription: 'Reminders for orders due for delivery',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelDeliveryReminder(int orderId) async {
    await _plugin.cancel(orderId);
  }

  Future<void> rescheduleAll() async {
    final orders = await OrderRepository().getAll();
    for (final o in orders) {
      if (o.deliveryDate != null && o.status != 'Delivered') {
        await scheduleDeliveryReminder(o);
      }
    }
  }
}
