import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Untuk mobile: simpan sebagai File
  File? _selectedImageFile;

  // Untuk web: simpan sebagai bytes (Image.file tidak support web)
  Uint8List? _selectedImageBytes;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _imageSource = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    NotificationService.requestPermission();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Ambil foto dari KAMERA ─────────────────────────────────────────────────
  Future<void> _ambilFotoKamera() async {
    setState(() => _isLoading = true);
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (foto != null) {
        // Web: baca sebagai bytes karena Image.file tidak support web
        if (kIsWeb) {
          final bytes = await foto.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageFile = null;
            _imageSource = 'Kamera 📸';
          });
        } else {
          // Mobile: gunakan File biasa
          setState(() {
            _selectedImageFile = File(foto.path);
            _selectedImageBytes = null;
            _imageSource = 'Kamera 📸';
          });
        }

        _fadeController.reset();
        _fadeController.forward();
        await NotificationService.showCameraNotification();

        if (mounted) {
          _showSnackBar('✅ Foto berhasil diambil dari kamera!', Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Gagal membuka kamera: $e', Colors.red);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Pilih foto dari GALERI ─────────────────────────────────────────────────
  Future<void> _pilihFotoGaleri() async {
    setState(() => _isLoading = true);
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (foto != null) {
        if (kIsWeb) {
          final bytes = await foto.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageFile = null;
            _imageSource = 'Galeri 🖼️';
          });
        } else {
          setState(() {
            _selectedImageFile = File(foto.path);
            _selectedImageBytes = null;
            _imageSource = 'Galeri 🖼️';
          });
        }

        _fadeController.reset();
        _fadeController.forward();
        await NotificationService.showGalleryNotification();

        if (mounted) {
          _showSnackBar('✅ Foto berhasil dipilih dari galeri!', Colors.blue);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Gagal membuka galeri: $e', Colors.red);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Cek apakah ada foto yang dipilih ──────────────────────────────────────
  bool get _hasImage =>
      _selectedImageBytes != null || _selectedImageFile != null;

  // ─── Build gambar sesuai platform ──────────────────────────────────────────
  Widget _buildImage() {
    if (_selectedImageBytes != null) {
      // Web: gunakan Image.memory dari bytes
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (_selectedImageFile != null) {
      // Mobile: gunakan Image.file
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dika Kamera',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_hasImage)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus Foto',
              onPressed: () {
                setState(() {
                  _selectedImageFile = null;
                  _selectedImageBytes = null;
                  _imageSource = '';
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildButtonSection(),
            const SizedBox(height: 28),
            _buildImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.white, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aplikasi Kamera & Notifikasi',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  kIsWeb
                      ? 'Silahkan Coba di Perangkat Mobile'
                      : 'Berjalan di Android/iOS',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.touch_app, size: 18, color: Colors.grey),
            SizedBox(width: 6),
            Text('Pilih Sumber Foto',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _CameraButton(
                icon: Icons.camera_alt,
                label: 'Buka Kamera',
                subtitle: 'Ambil foto langsung',
                color: const Color(0xFF1A73E8),
                isLoading: _isLoading,
                onPressed: _ambilFotoKamera,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CameraButton(
                icon: Icons.photo_library,
                label: 'Pilih Galeri',
                subtitle: 'Foto yang ada',
                color: const Color(0xFF34A853),
                isLoading: _isLoading,
                onPressed: _pilihFotoGaleri,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            const Text('Hasil Foto',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            if (_imageSource.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF1A73E8).withOpacity(0.3)),
                ),
                child: Text(_imageSource,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A73E8))),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _hasImage ? 320 : 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: _hasImage
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: _hasImage
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildImage(),
                )
              : _buildPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 64, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text('Belum ada foto',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text('Gunakan tombol di atas untuk\nmengambil atau memilih foto',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      ],
    );
  }
}

// ─── Custom Widget Tombol ──────────────────────────────────────────────────────
class _CameraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _CameraButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}