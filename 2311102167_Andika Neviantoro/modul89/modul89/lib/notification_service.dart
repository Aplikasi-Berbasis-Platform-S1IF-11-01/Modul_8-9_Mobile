import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

/// Service class untuk mengelola semua fungsi notifikasi lokal
class NotificationService {
  // ID unik untuk notifikasi kamera
  static const int _cameraNotifId = 1001;

  // ID unik untuk notifikasi galeri
  static const int _galleryNotifId = 1002;

  /// Meminta izin notifikasi (khusus Android 13+)
  static Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Menampilkan notifikasi ketika foto berhasil diambil dari KAMERA
  static Future<void> showCameraNotification() async {
    // Detail notifikasi khusus Android
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'camera_channel',          // Channel ID (wajib unik)
      'Kamera Notifikasi',       // Nama channel yang tampil di pengaturan HP
      channelDescription: 'Notifikasi setelah mengambil foto dari kamera',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      color: Color(0xFF1A73E8),  // Warna aksen notifikasi (import dart:ui tidak perlu)
    );

    // Gabungkan detail lintas platform
    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Tampilkan notifikasi
    await flutterLocalNotificationsPlugin.show(
      _cameraNotifId,                    // ID notifikasi
      '📸 Foto Berhasil Diambil!',       // Judul notifikasi
      'Foto dari kamera telah berhasil ditangkap dan siap digunakan.',
      notifDetails,
    );
  }

  /// Menampilkan notifikasi ketika foto berhasil dipilih dari GALERI
  static Future<void> showGalleryNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'gallery_channel',
      'Galeri Notifikasi',
      channelDescription: 'Notifikasi setelah memilih foto dari galeri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      _galleryNotifId,
      '🖼️ Foto Berhasil Dipilih!',
      'Foto dari galeri telah berhasil dipilih dan ditampilkan.',
      notifDetails,
    );
  }
}