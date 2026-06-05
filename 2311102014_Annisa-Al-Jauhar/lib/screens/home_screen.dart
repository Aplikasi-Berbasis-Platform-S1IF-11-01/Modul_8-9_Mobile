import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  static const Color pastelBlue   = Color(0xFFB5C8F0);
  static const Color pastelPink   = Color(0xFFF0B5D8);
  static const Color pastelPurple = Color(0xFFD4B5F0);
  static const Color bgColor      = Color(0xFFF7F0FA);
  static const Color textDark     = Color(0xFF3A3A5C);

  Future<void> _ambilDariKamera() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (foto != null) {
      final bytes = await foto.readAsBytes();
      setState(() => _imageBytes = bytes);
      await NotificationService.tampilkanNotifikasi(judul: 'Foto Berhasil Diambil!', isi: 'Foto baru telah diambil menggunakan kamera.');
    }
  }

  Future<void> _pilihDariGaleri() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto != null) {
      final bytes = await foto.readAsBytes();
      setState(() => _imageBytes = bytes);
      await NotificationService.tampilkanNotifikasi(judul: 'Foto Dipilih dari Galeri!', isi: 'Foto berhasil dipilih dari galeri perangkat.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: pastelPurple,
        elevation: 0,
        title: const Text('Foto & Notifikasi', style: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildCard(title: 'Ambil Foto', child: Column(children: [
              _buildTombol(label: 'Buka Kamera', icon: Icons.camera_alt_rounded, warna: pastelBlue, onTap: _ambilDariKamera),
              const SizedBox(height: 14),
              _buildTombol(label: 'Pilih dari Galeri', icon: Icons.photo_library_rounded, warna: pastelPink, onTap: _pilihDariGaleri),
            ])),
            const SizedBox(height: 24),
            _buildCard(title: 'Preview Foto', child: _imageBytes == null ? _buildEmptyState() : _buildImagePreview()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: pastelPurple.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _buildTombol({required String label, required IconData icon, required Color warna, required VoidCallback onTap}) {
    return SizedBox(width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: warna, foregroundColor: textDark, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14)),
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(width: double.infinity, height: 200,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pastelPurple.withOpacity(0.5), width: 2)),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_outlined, size: 56, color: Color(0xFFD4B5F0)),
        SizedBox(height: 12),
        Text('Belum ada foto dipilih', style: TextStyle(color: Color(0xFF9B9BB8), fontSize: 14)),
      ]),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(borderRadius: BorderRadius.circular(16),
      child: Image.memory(_imageBytes!, width: double.infinity, height: 280, fit: BoxFit.cover));
  }
}
