// ============================================================
// main.dart
// Project  : Notifikasi & API Perangkat Keras
// Deskripsi: Demonstrasi penggunaan kamera, galeri, dan local
//            notification pada Flutter (Praktikum Mobile)
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Inisialisasi plugin notifikasi (global) ──────────────────
// Dibuat di luar class agar bisa diakses dari mana saja
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─── Entry point aplikasi ─────────────────────────────────────
void main() async {
  // Pastikan binding Flutter sudah siap sebelum inisialisasi plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi local notifications
  await _initNotifications();

  runApp(const MyApp());
}

// ─── Fungsi inisialisasi Flutter Local Notifications ─────────
Future<void> _initNotifications() async {
  // Pengaturan untuk platform Android
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // ikon default app

  // Gabungkan pengaturan semua platform
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  // Lakukan inisialisasi; callback onDidReceiveNotificationResponse
  // dipanggil saat user mengetuk notifikasi
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Bisa digunakan untuk navigasi atau aksi tertentu saat notif diklik
      debugPrint('Notifikasi diklik: ${response.payload}');
    },
  );
}

// ─── Root Widget ──────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifikasi & Hardware API',
      debugShowCheckedModeBanner: false, // Hilangkan banner debug
      theme: ThemeData(
        // Warna utama aplikasi (Material 3)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // ungu modern
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Font custom agar lebih modern
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// ─── Halaman Utama ────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel untuk menyimpan file gambar yang dipilih/diambil
  File? _imageFile;

  // Instance ImagePicker untuk mengakses kamera & galeri
  final ImagePicker _picker = ImagePicker();

  // Status loading saat kamera/galeri sedang dibuka
  bool _isLoading = false;

  // Pesan sumber gambar (Kamera / Galeri)
  String _imageSource = '';

  // ── 1. Fungsi: Ambil Foto dari Kamera ──────────────────────
  Future<void> _pickFromCamera() async {
    // Minta izin kamera terlebih dahulu
    final cameraStatus = await Permission.camera.request();

    if (!cameraStatus.isGranted) {
      _showSnackBar('Izin kamera diperlukan untuk fitur ini.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buka kamera dan ambil foto
      // imageQuality: 85 = kompres 85% agar tidak terlalu berat
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (photo != null) {
        // Update state dengan file gambar baru
        setState(() {
          _imageFile = File(photo.path);
          _imageSource = 'Kamera';
        });

        // Tampilkan notifikasi setelah foto berhasil diambil
        await _showNotification(
          title: '📸 Foto Berhasil Diambil',
          body: 'Gambar dari kamera berhasil ditambahkan ke aplikasi.',
          payload: 'camera',
        );
      }
    } catch (e) {
      // Tangani error (misalnya kamera tidak tersedia di emulator)
      _showSnackBar('Gagal membuka kamera: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── 2. Fungsi: Ambil Gambar dari Galeri ────────────────────
  Future<void> _pickFromGallery() async {
    // Minta izin akses penyimpanan / media
    final storageStatus = await Permission.photos.request();

    // Jika izin ditolak, coba izin storage biasa (Android < 13)
    if (!storageStatus.isGranted) {
      final legacyStatus = await Permission.storage.request();
      if (!legacyStatus.isGranted) {
        _showSnackBar('Izin galeri diperlukan untuk fitur ini.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Buka galeri dan pilih gambar
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _imageSource = 'Galeri';
        });

        // Tampilkan notifikasi setelah gambar dipilih
        await _showNotification(
          title: '🖼️ Gambar Dipilih',
          body: 'Gambar dari galeri berhasil ditambahkan ke aplikasi.',
          payload: 'gallery',
        );
      }
    } catch (e) {
      _showSnackBar('Gagal membuka galeri: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── 3. Fungsi: Tampilkan Local Notification ────────────────
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Konfigurasi detail notifikasi untuk Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'foto_channel_id', // ID channel (unik per kategori notifikasi)
      'Foto & Galeri',   // Nama channel (ditampilkan di pengaturan notif)
      channelDescription: 'Notifikasi untuk aktivitas kamera dan galeri',
      importance: Importance.high,   // Prioritas notifikasi
      priority: Priority.high,
      showWhen: true,                // Tampilkan waktu notifikasi
      icon: '@mipmap/ic_launcher',  // Ikon notifikasi
      color: Color(0xFF6C63FF),     // Warna aksen notifikasi
    );

    // Gabungkan detail notifikasi semua platform
    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    // Tampilkan notifikasi dengan ID unik
    // Menggunakan DateTime.now().millisecond agar setiap notif punya ID berbeda
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // ID notifikasi
      title,                       // Judul notifikasi
      body,                        // Isi pesan notifikasi
      notifDetails,
      payload: payload,            // Data opsional saat notif diklik
    );
  }

  // ── Helper: Tampilkan SnackBar untuk pesan error/info ──────
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Fungsi: Hapus Gambar ───────────────────────────────────
  void _clearImage() {
    setState(() {
      _imageFile = null;
      _imageSource = '';
    });
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD: Tampilan UI Utama
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ── AppBar ──────────────────────────────────────────────
      appBar: AppBar(
        title: const Text(
          'Notifikasi & API Perangkat Keras',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // ── Body ────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Bagian Header Info ─────────────────────────
            _buildInfoCard(colorScheme),

            const SizedBox(height: 24),

            // ── Preview Gambar ─────────────────────────────
            _buildImagePreview(colorScheme),

            const SizedBox(height: 24),

            // ── Tombol Aksi ────────────────────────────────
            _buildActionButtons(colorScheme),

            const SizedBox(height: 16),

            // ── Info Notifikasi ────────────────────────────
            _buildNotificationInfo(colorScheme),
          ],
        ),
      ),
    );
  }

  // ── Widget: Kartu Info ──────────────────────────────────────
  Widget _buildInfoCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Praktikum Mobile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan tombol di bawah untuk mengakses Kamera, Galeri, dan melihat Local Notification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Preview Gambar ──────────────────────────────────
  Widget _buildImagePreview(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 4 / 3, // Rasio gambar preview
          child: _isLoading
              // ─ Loading State ─
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Membuka...',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                )
              : _imageFile != null
                  // ─ Ada Gambar: Tampilkan Preview ─
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover, // Penuhi seluruh area
                        ),
                        // Badge sumber gambar (Kamera / Galeri)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _imageSource == 'Kamera'
                                      ? Icons.camera_alt
                                      : Icons.photo_library,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _imageSource,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tombol hapus gambar
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _clearImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  // ─ Belum Ada Gambar: Tampilkan Placeholder ─
                  : Container(
                      color: colorScheme.surfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada gambar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ambil foto atau pilih dari galeri',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  // ── Widget: Tombol Aksi ─────────────────────────────────────
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─ Tombol Kamera ─
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _pickFromCamera,
          icon: const Icon(Icons.camera_alt_rounded, size: 22),
          label: const Text(
            'Buka Kamera',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colorScheme.primary.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
          ),
        ),

        const SizedBox(height: 12),

        // ─ Tombol Galeri ─
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _pickFromGallery,
          icon: Icon(Icons.photo_library_rounded,
              size: 22, color: colorScheme.primary),
          label: Text(
            'Pilih dari Galeri',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget: Kotak Info Notifikasi ───────────────────────────
  Widget _buildNotificationInfo(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.tertiary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_rounded,
            color: colorScheme.tertiary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local Notification Aktif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Setiap kali foto berhasil diambil atau dipilih, sistem akan otomatis mengirimkan notifikasi lokal ke perangkat.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.65),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
