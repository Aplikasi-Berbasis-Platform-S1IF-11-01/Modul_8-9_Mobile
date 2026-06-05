import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {},
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifikasi & Kamera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  OverlayEntry? _bannerEntry;

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'photo_channel',
      'Photo Notifications',
      channelDescription: 'Notifications when a photo is taken or picked',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );

    // also show a small in-app banner for immediate feedback
    if (mounted) _showInAppBanner(body);
  }

  void _showInAppBanner(String text) {
    // remove existing
    _bannerEntry?.remove();

    _bannerEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 32,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_bannerEntry!);
    Future.delayed(const Duration(seconds: 2), () {
      _bannerEntry?.remove();
      _bannerEntry = null;
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _imageFile = File(picked.path));
      await _showNotification('Foto Dipilih', 'Foto berhasil dipilih dari galeri.');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  Future<void> _openCamera() async {
    // Navigate to camera page which uses camera API
    final String? imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (imagePath != null) {
      if (!mounted) return;
      setState(() => _imageFile = File(imagePath));
      await _showNotification('Foto Diambil', 'Foto berhasil diambil menggunakan kamera.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Notification permission may be requested on Android 13+ by the system
    // or via a permissions plugin if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFa0e9ff), Color(0xFF69e0d0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('Camera App', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                const Text('Ambil atau pilih foto dengan mudah', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 18),

                // image card
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0,8))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AspectRatio(
                          aspectRatio: 4/3,
                          child: _imageFile == null
                              ? Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.image, size: 86, color: Colors.blueGrey),
                                        SizedBox(height: 10),
                                        Text('Belum ada foto', style: TextStyle(color: Colors.black45)),
                                      ],
                                    ),
                                  ),
                                )
                              : Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _GradientButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Buka Kamera',
                        colors: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        onPressed: _openCamera,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GradientButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Pilih dari Galeri',
                        colors: const [Color(0xFF8e54e9), Color(0xFF4776e6)],
                        onPressed: _pickFromGallery,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onPressed;

  const _GradientButton({required this.icon, required this.label, required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: colors.last.withOpacity(0.25), blurRadius: 8, offset: Offset(0,6))],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      _controller = CameraController(back, ResolutionPreset.medium, enableAudio: false);
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal inisialisasi kamera: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) Navigator.of(context).pop(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamera')),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller!),
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: _takePicture,
                              child: const Icon(Icons.camera),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
