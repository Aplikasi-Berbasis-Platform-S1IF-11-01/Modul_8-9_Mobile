import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Inisialisasi plugin notifikasi (global) ───────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications(); // inisialisasi notifikasi sebelum app jalan
  runApp(const MyApp());
}

// ─── Setup notifikasi ──────────────────────────────────────────────────────
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // ikon notifikasi

  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

// ─── Root Widget ───────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto & Notifikasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Halaman Utama ─────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage; // menyimpan foto yang dipilih/diambil
  final ImagePicker _picker = ImagePicker(); // instance image_picker

  // ── Ambil foto dari KAMERA ────────────────────────────────────────────
  Future<void> _ambilDariKamera() async {
    // Minta izin kamera
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _tampilSnackBar('Izin kamera ditolak');
      return;
    }

    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // kompres kualitas agar tidak terlalu besar
    );

    if (foto != null) {
      setState(() => _selectedImage = File(foto.path));
      await _kirimNotifikasi('📸 Foto dari Kamera', 'Foto berhasil diambil menggunakan kamera!');
    }
  }

  // ── Pilih foto dari GALERI ────────────────────────────────────────────
  Future<void> _pilihDariGaleri() async {
    // Minta izin storage (untuk Android < 13)
    final status = await Permission.photos.request();
    // Jika denied, tetap coba (Android 13+ tidak butuh izin ini)

    final XFile? foto = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (foto != null) {
      setState(() => _selectedImage = File(foto.path));
      await _kirimNotifikasi('🖼️ Foto dari Galeri', 'Foto berhasil dipilih dari galeri!');
    }
  }

  // ── Kirim notifikasi lokal ────────────────────────────────────────────
  Future<void> _kirimNotifikasi(String judul, String pesan) async {
    // Minta izin notifikasi (Android 13+)
    await Permission.notification.request();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'foto_channel',        // channel ID (unik)
      'Notifikasi Foto',     // channel name
      channelDescription: 'Notifikasi saat foto diambil atau dipilih',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,       // ID notifikasi
      judul,   // judul
      pesan,   // isi pesan
      details,
    );
  }

  // ── Tampilkan SnackBar pesan error ────────────────────────────────────
  void _tampilSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red),
    );
  }

  // ── Build UI ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──
      appBar: AppBar(
        title: const Text('Foto & Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Area tampil foto ──────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover, // foto memenuhi container
                  ),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada foto',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Kamera ─────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _ambilDariKamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Buka Kamera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tombol Galeri ─────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _pilihDariGaleri,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}