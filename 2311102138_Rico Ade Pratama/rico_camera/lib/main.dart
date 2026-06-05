import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request();
  await NotificationService.init();
  runApp(const MyApp());
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'photo_channel',
          'Photo Notifications',
          channelDescription: 'Notifikasi setelah foto berhasil',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(0, title, body, details);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 08-09 - Rico Camera',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE63946),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        if (source == ImageSource.camera) {
          await NotificationService.showNotification(
            'Sukses',
            'Foto berhasil diambil',
          );
        } else {
          await NotificationService.showNotification(
            'Sukses',
            'Foto berhasil dipilih',
          );
        }
      }
    } catch (e) {
      debugPrint("Error mengambil gambar: $e");
    }
  }

  Widget buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    if (_image == null) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2D),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black45,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 80, color: Colors.white30),
              SizedBox(height: 15),
              Text(
                'Belum ada foto',
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black54,
            offset: Offset(0, 10),
          ),
        ],
        image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1D), Color(0xFF0D0D0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'RICAMERA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Color(0xFFE63946),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ambil atau pilih foto dengan mudah',
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
                const SizedBox(height: 30),
                buildImagePreview(),
                const SizedBox(height: 30),
                buildButton(
                  text: 'Buka Kamera',
                  icon: Icons.camera_alt,
                  color: const Color(0xFFC8102E),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 15),
                buildButton(
                  text: 'Pilih dari Galeri',
                  icon: Icons.photo_library,
                  color: const Color(0xFF8B0000),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                const Spacer(),
                const Text(
                  'NIM: 2311102138',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
