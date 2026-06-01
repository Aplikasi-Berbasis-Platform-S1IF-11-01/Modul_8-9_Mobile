import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Inisialisasi plugin notifikasi secara global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // Memastikan Flutter binding sudah siap sebelum menjalankan app
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi inisialisasi untuk Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Konfigurasi inisialisasi gabungan (Android + iOS)
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // Menginisialisasi plugin notifikasi
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: widget root untuk aplikasi Material Design
    return MaterialApp(
      title: 'Foto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  // Menyimpan file foto yang dipilih/diambil
  File? _imageFile;

  // Instance ImagePicker untuk mengakses kamera dan galeri
  final ImagePicker _picker = ImagePicker();

  // Fungsi menampilkan notifikasi lokal
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'foto_channel_id',   // ID channel (harus unik)
      'Foto Notifications', // Nama channel
      channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Menampilkan notifikasi dengan ID 0
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Fungsi mengambil foto menggunakan kamera
  Future<void> _ambilFotoKamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera, // Membuka kamera perangkat
      imageQuality: 80,           // Kualitas gambar 80%
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path); // Menyimpan file foto
      });

      // Tampilkan notifikasi setelah foto berhasil diambil
      await _showNotification(
        '📷 Foto Berhasil Diambil!',
        'Foto dari kamera sudah tersimpan dan ditampilkan.',
      );
    }
  }

  // Fungsi memilih foto dari galeri
  Future<void> _pilihFotoGaleri() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery, // Membuka galeri foto
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path); // Menyimpan file foto
      });

      // Tampilkan notifikasi setelah foto berhasil dipilih
      await _showNotification(
        '🖼️ Foto Berhasil Dipilih!',
        'Foto dari galeri berhasil dimuat ke aplikasi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman (AppBar + body)
    return Scaffold(
      appBar: AppBar(
        // AppBar: bilah judul di bagian atas layar
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Foto App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        // Padding: memberikan jarak di sekeliling konten
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Column: menyusun widget secara vertikal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container: kotak untuk menampilkan preview foto
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      // ClipRRect: memotong gambar dengan sudut membulat
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        // Image.file: menampilkan gambar dari file lokal
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Foto akan tampil di sini',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // Row: menyusun dua tombol secara horizontal
            Row(
              children: [
                // Tombol pertama: Buka Kamera
                Expanded(
                  child: ElevatedButton.icon(
                    // ElevatedButton: tombol dengan efek bayangan
                    onPressed: _ambilFotoKamera,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Kamera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol kedua: Pilih dari Galeri
                Expanded(
                  child: OutlinedButton.icon(
                    // OutlinedButton: tombol dengan garis tepi
                    onPressed: _pilihFotoGaleri,
                    icon: Icon(Icons.photo_library, color: Colors.blue[700]),
                    label: Text(
                      'Galeri',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.blue[700]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Menampilkan keterangan sumber foto jika sudah ada
            if (_imageFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Foto berhasil dimuat!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}