import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _ambilFotoKamera() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
      await NotificationService.showNotification(
        title: '📷 Foto Berhasil Diambil',
        body: 'Foto dari kamera telah berhasil diambil dan ditampilkan.',
      );
    }
  }

  Future<void> _pilihDariGaleri() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      await NotificationService.showNotification(
        title: '🖼️ Foto Berhasil Dipilih',
        body: 'Foto dari galeri telah berhasil dipilih dan ditampilkan.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera & Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tombol 1: Kamera
            ElevatedButton.icon(
              onPressed: _ambilFotoKamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Buka Kamera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol 2: Galeri
            ElevatedButton.icon(
              onPressed: _pilihDariGaleri,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Tampilan Foto
            Expanded(
              child: _selectedImage != null
                  ? Column(
                      children: [
                        const Text(
                          'Foto yang Dipilih:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada foto.\nTekan tombol di atas untuk mulai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}