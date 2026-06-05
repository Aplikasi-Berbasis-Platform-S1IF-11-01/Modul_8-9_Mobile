import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Pastikan binding Flutter sudah siap sebelum inisialisasi plugin
  WidgetsFlutterBinding.ensureInitialized();

  // ── Konfigurasi Android Initialization Settings ──
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Ikon notifikasi

  // ── Gabungkan semua platform settings ──
  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
  );

  // ── Inisialisasi plugin ──
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ── Minta permission notifikasi (Android 13+) ──
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}
// ROOT APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera & Notifikasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FotoPickerPage(),
    );
  }
}
// HALAMAN UTAMA
class FotoPickerPage extends StatefulWidget {
  const FotoPickerPage({super.key});

  @override
  State<FotoPickerPage> createState() => _FotoPickerPageState();
}

class _FotoPickerPageState extends State<FotoPickerPage> {
  File? _imageFile; // Menyimpan file foto yang dipilih
  bool _isLoading = false; // Indikator loading saat mengambil foto

  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker


  // Ambil foto dari Kamera atau Galeri
  
  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      // Membuka kamera atau galeri sesuai [source]
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Kompres kualitas gambar (0-100)
        maxWidth: 1080, // Batasi lebar maksimal
      );

      if (pickedFile != null) {
        // Jika foto berhasil dipilih, update state
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Tampilkan notifikasi lokal setelah foto berhasil dimuat
        await _showNotification();
      }
    } catch (e) {
      // Tampilkan error jika terjadi masalah (misal: permission ditolak)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Selalu matikan loading indicator setelah selesai
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // Tampilkan Notifikasi Lokal
  Future<void> _showNotification() async {
    // Konfigurasi detail notifikasi untuk Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'foto_channel_id', // Channel ID (unik)
      'Notifikasi Foto', // Nama channel (tampil di pengaturan HP)
      channelDescription: 'Notifikasi saat foto berhasil ditambahkan',
      importance: Importance.high, // Prioritas notifikasi
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Ikon notifikasi
      playSound: true, // Mainkan suara
    );

    // Gabungkan detail untuk semua platform
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Tampilkan notifikasi
    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi (0 = selalu timpa notif sebelumnya)
      '📸 Foto Berhasil!', // Judul notifikasi
      'Foto berhasil ditambahkan!', // Isi pesan notifikasi
      notificationDetails,
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera & Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ── Area Tampilan Foto ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _buildImagePreview(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Kamera & Galeri ──
            Row(
              children: [
                // Tombol Kamera
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null // Nonaktifkan saat loading
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol Galeri
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Preview Gambar / Placeholder
  Widget _buildImagePreview() {
    // Tampilkan loading indicator
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat foto...'),
          ],
        ),
      );
    }

    // Tampilkan foto jika sudah ada
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Tampilkan placeholder jika belum ada foto
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Belum ada foto',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Ambil foto via Kamera atau pilih dari Galeri',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
