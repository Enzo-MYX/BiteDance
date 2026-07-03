import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);
  }

  static Future<void> requestNotificationPermission() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('Android notification permission: $granted');
    }
    final iosImplementation = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
      print('iOS notification permission: $granted');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'bitedance_channel',
      'BiteDance Events',
      channelDescription: 'Notifications for new free food events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}