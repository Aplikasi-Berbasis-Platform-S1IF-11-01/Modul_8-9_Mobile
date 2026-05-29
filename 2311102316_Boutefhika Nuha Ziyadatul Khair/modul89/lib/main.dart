import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Kawaii',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
        ),
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
  // Simpan sebagai bytes agar support Web & Mobile
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // ── Notifikasi ────────────────────────────────────────────────────────────
  Future<void> _showNotification(String source) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'snap_kawaii_ch',
      'Snap Kawaii',
      channelDescription: 'Notifikasi foto',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      source == 'camera' ? '📸 Foto tersimpan!' : '🖼️ Foto dipilih!',
      source == 'camera'
          ? 'Foto dari kamera berhasil diambil.'
          : 'Foto dari galeri berhasil dipilih.',
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  // ── Ambil dari Kamera ─────────────────────────────────────────────────────
  Future<void> _takePhotoFromCamera() async {
    setState(() => _isLoading = true);
    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) {
        // readAsBytes() support Web & Mobile
        final bytes = await photo.readAsBytes();
        setState(() => _imageBytes = bytes);
        await _showNotification('camera');
        _snack('Foto dari kamera berhasil!');
      }
    } catch (e) {
      _snack('Gagal membuka kamera.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Ambil dari Galeri ─────────────────────────────────────────────────────
  Future<void> _pickPhotoFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() => _imageBytes = bytes);
        await _showNotification('gallery');
        _snack('Foto dari galeri berhasil!');
      }
    } catch (e) {
      _snack('Gagal membuka galeri.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Color(0xFF6D3B52), fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFD6E4),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB6C8),
        elevation: 0,
        title: const Text(
          'Snap Kawaii ✿',
          style: TextStyle(
            color: Color(0xFF6D3B52),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Area foto ──────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFFFB6C8), width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildImageArea(),
              ),
            ),
            const SizedBox(height: 20),
            // ── Tombol Kamera ──────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isLoading ? null : _takePhotoFromCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Buka Kamera',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            // ── Tombol Galeri ──────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickPhotoFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B9D),
                side: const BorderSide(
                    color: Color(0xFFFF6B9D), width: 1.5),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Area tampilan foto ─────────────────────────────────────────────────────
  Widget _buildImageArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
      );
    }
    if (_imageBytes != null) {
      // Image.memory — support Web & Mobile (pakai bytes, bukan File)
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 56, color: Color(0xFFFFB6C8)),
          SizedBox(height: 12),
          Text(
            'Belum ada foto',
            style: TextStyle(
              color: Color(0xFFB07A95),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tekan tombol di bawah',
            style: TextStyle(color: Color(0xFFCBA8BB), fontSize: 13),
          ),
        ],
      ),
    );
  }
}