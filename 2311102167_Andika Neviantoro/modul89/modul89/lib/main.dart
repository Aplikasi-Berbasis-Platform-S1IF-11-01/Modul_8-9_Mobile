import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_page.dart';

// Instance global plugin notifikasi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  // Memastikan Flutter binding sudah siap sebelum inisialisasi plugin
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Inisialisasi Notifikasi ───────────────────────────────────────────────
  // Setting untuk Android: nama ikon notifikasi (harus ada di drawable)
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // Setting untuk iOS
  const DarwinInitializationSettings iosSettings =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Gabungkan setting Android & iOS
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  // Inisialisasi plugin dengan setting di atas
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ─── Jalankan Aplikasi ─────────────────────────────────────────────────────
  runApp(const MyApp());
}

/// Widget root aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum Kamera & Notifikasi',
      debugShowCheckedModeBanner: false,

      // ─── Tema Aplikasi ────────────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      home: const HomePage(),
    );
  }
}