import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// Global list to store available cameras
List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize camera list
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
  }

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

/// A Singleton Notification Service to handle local notifications and permissions.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked!");
      },
    );
  }

  Future<void> showNotification({required String title, required String body}) async {
    if (Platform.isAndroid) {
      // Check and request POST_NOTIFICATIONS permission for Android 13+
      final status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        await Permission.notification.request();
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'camera_app_channel_id',
      'Camera & Photo App Notifications',
      channelDescription: 'Notifications for photo captures and selections',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifikasi & Kamera Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F12), // Deep Obsidian Dark
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Neon Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF00FFD1), // Electric Cyan
          surface: const Color(0xFF1E1E24),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF131317),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
      home: const PremiumHomeScreen(),
    );
  }
}

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-request notification permission at startup
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  // Method to open custom Camera screen (using Camera API)
  Future<void> _takePhotoWithCameraAPI() async {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Kamera tidak terdeteksi atau tidak tersedia.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Request camera permission
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Izin kamera ditolak. Silakan aktifkan di pengaturan.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Open Custom Camera Screen
    final String? imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: cameras.first),
      ),
    );

    if (!mounted) return;

    if (imagePath != null) {
      setState(() {
        _selectedImage = File(imagePath);
      });

      // Trigger Local Notification
      await NotificationService().showNotification(
        title: '📸 Foto Berhasil Diambil!',
        body: 'Foto baru berhasil ditangkap menggunakan Camera API dan siap ditampilkan.',
      );
    }
  }

  // Method to pick photo from gallery using image_picker
  Future<void> _pickPhotoFromGallery() async {
    // Request gallery / storage permission
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Trigger Local Notification
      await NotificationService().showNotification(
        title: '🖼️ Foto Berhasil Dipilih!',
        body: 'Foto dari galeri Anda berhasil dimuat dan siap ditampilkan.',
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Foto berhasil dihapus.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_back, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            const Text('SNAP & NOTIFY'),
          ],
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'Hapus Foto',
              onPressed: _clearImage,
            )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F12), Color(0xFF1A1A24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header Block
              const SizedBox(height: 10),
              const Text(
                'Uji Coba Fitur Perangkat Keras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00FFD1),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ambil Foto & Notifikasi Lokal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Image Frame / Placeholder Container (Expanded)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF181820),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: _selectedImage != null
                          ? const Color(0xFF00FFD1).withOpacity(0.5)
                          : Colors.white.withOpacity(0.05),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedImage != null
                            ? const Color(0xFF00FFD1).withOpacity(0.1)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                            // Glassmorphism photo info tag
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.0,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF00FFD1), size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Foto berhasil dimuat',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Abstract decorative icon representation
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222230),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF6366F1).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.image_search_rounded,
                                  size: 36,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Belum Ada Foto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gunakan salah satu tombol di bawah untuk mengambil gambar dari Kamera langsung atau memilih dari Galeri.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Buttons Block
              Row(
                children: [
                  // Button 1: Camera API
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _takePhotoWithCameraAPI,
                        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                        label: const Text(
                          'Kamera',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Button 2: Image Picker Gallery
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E24), Color(0xFF2B2B36)],
                        ),
                        border: Border.all(
                          color: const Color(0xFF00FFD1).withOpacity(0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFD1).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _pickPhotoFromGallery,
                        icon: const Icon(Icons.photo_library_rounded, color: Color(0xFF00FFD1)),
                        label: const Text(
                          'Galeri',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FFD1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Camera UI providing direct interaction with the Camera API.
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false, // Audio not needed for taking still photos
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();
      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Gagal mengambil foto: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                
                // Camera Grid Lines (Rule of Thirds Overlay)
                Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                          Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5)))),
                        ],
                      ),
                    ),
                  ],
                ),

                // Top Controls (Back Button)
                Positioned(
                  top: 48,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Bottom Capture Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 140,
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shutter button
                        GestureDetector(
                          onTap: _capturePhoto,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00FFD1)),
                  SizedBox(height: 16),
                  Text(
                    'Menyiapkan Kamera...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
