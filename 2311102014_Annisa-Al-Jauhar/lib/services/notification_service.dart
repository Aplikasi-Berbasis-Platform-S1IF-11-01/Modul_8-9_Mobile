import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(initSettings);
    final plugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.requestNotificationsPermission();
  }

  static Future<void> tampilkanNotifikasi({required String judul, required String isi}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('foto_channel', 'Foto & Notifikasi',
          channelDescription: 'Notifikasi foto',
          importance: Importance.high,
          priority: Priority.high),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, judul, isi, details);
  }
}
