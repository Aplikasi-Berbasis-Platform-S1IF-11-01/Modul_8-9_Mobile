import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const MyApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await notificationsPlugin.initialize(initSettings);
}

Future<void> showNotification(String message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'foto_channel',
    'Foto Notifikasi',
    channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
  );
  await notificationsPlugin.show(0, 'Foto Berhasil', message, details);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeri Foto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8EAFC2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const FotoPage(),
    );
  }
}

class FotoPage extends StatefulWidget {
  const FotoPage({super.key});

  @override
  State<FotoPage> createState() => _FotoPageState();
}

class _FotoPageState extends State<FotoPage> {
  File? _foto;
  final ImagePicker _picker = ImagePicker();

  static const Color bgColor = Color(0xFFF4F0EB);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentBlue = Color(0xFF8EAFC2);
  static const Color accentSage = Color(0xFFA8BCA1);
  static const Color textDark = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9E9E9E);

  Future<void> ambilDariKamera() async {
    final XFile? hasil = await _picker.pickImage(source: ImageSource.camera);
    if (hasil != null) {
      setState(() => _foto = File(hasil.path));
      await showNotification('Foto berhasil diambil dari kamera.');
    }
  }

  Future<void> pilihDariGaleri() async {
    final XFile? hasil = await _picker.pickImage(source: ImageSource.gallery);
    if (hasil != null) {
      setState(() => _foto = File(hasil.path));
      await showNotification('Foto berhasil dipilih dari galeri.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Galeri Foto',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ambil atau pilih foto dari perangkat kamu',
                style: TextStyle(fontSize: 14, color: textLight),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      subtitle: 'Ambil foto baru',
                      color: accentBlue,
                      onTap: ambilDariKamera,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      subtitle: 'Pilih dari album',
                      color: accentSage,
                      onTap: pilihDariGaleri,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _foto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          _foto!,
                          width: double.infinity,
                          height: 360,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        height: 360,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFFF9F6F2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Color(0xFFCEC8C0),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada foto',
                              style: TextStyle(
                                fontSize: 16,
                                color: textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gunakan tombol di atas untuk mulai',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBEB8B0),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}
