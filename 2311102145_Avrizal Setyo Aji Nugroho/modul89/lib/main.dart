import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false, // Menghilangkan pita debug
    home: HomePage(),
  ),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Inisialisasi Notifikasi
  // Inisialisasi Notifikasi
  void _initializeNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notificationsPlugin.initialize(initializationSettings);

    // ==========================================================
    // TAMBAHAN: Meminta izin notifikasi (Wajib untuk Android 13+)
    // ==========================================================
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  // Fungsi Tampil Notifikasi
  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Foto Notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notificationsPlugin.show(
      0,
      'Sukses!',
      'Foto berhasil dimuat.',
      const NotificationDetails(android: androidDetails),
    );
  }

  // Fungsi Ambil/Pilih Foto
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      _showNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang aplikasi
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text(
          "Tugas Kamera & Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Jarak aman dari tepi layar
        child: Column(
          children: [
            // Area Preview Gambar
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 80,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Belum ada foto yang dipilih",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover, // Gambar memenuhi area kontainer
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32), // Jarak antara gambar dan tombol
            // Area Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Kamera
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Kamera", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Galeri
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
