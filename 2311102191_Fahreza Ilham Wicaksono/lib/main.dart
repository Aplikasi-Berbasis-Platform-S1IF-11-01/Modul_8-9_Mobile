import 'package:flutter/material.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera dan Notifikasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE8EDF2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF547A95)),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const ImageNotificationPage(),
    );
  }
}

class ImageNotificationPage extends StatefulWidget {
  const ImageNotificationPage({super.key});

  @override
  State<ImageNotificationPage> createState() => _ImageNotificationPageState();
}

class _ImageNotificationPageState extends State<ImageNotificationPage> {
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }
  
  // Fungsi untuk setup dan izin notifikasi
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings
    );

    //  Jalankan init
    await _localNotificationsPlugin.initialize(initializationSettings);

    // Izin notifikasi
    await _localNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
  }

  // Fungsi untuk menampilkan notifikasi lokal
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel_foto_id',
          'FAAAHHHH Notifikasi Foto',
          channelDescription: 'FAAHHH Foto berhasil dipilih',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Menampilkan notifikasi secara langsung
    await _localNotificationsPlugin.show(
      0,
      'Foto berhasil dipilih nich',
      'FAAAHHHH!! Fotonya sudah masuk',
      notificationDetails,
    );
  }

  // Fungsi untuk mengambil fotp
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Panggil notifikasi
        await _showNotification();
      }
    } catch (error) {
      debugPrint('Error mengambil gambar: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera dan Notifikasi'),
        backgroundColor: const Color(0xFFC2A56D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C3947)),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Text(
                        'Belum ada foto yang dipilih',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 30),

            // Tombol buka kamera
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera), // parameter source kamera
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Buka kamera'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol ambil dari galeri
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery), // parameter source galeri
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Pilih dari Galeri'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
