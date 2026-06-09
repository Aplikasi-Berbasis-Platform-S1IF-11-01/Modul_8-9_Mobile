import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Palet Warna ──────────────────────────────────────────────
const Color kNavy = Color(0xFF1E3A5F); // biru tua utama
const Color kNavyLight = Color(
  0xFF2E5590,
); // biru tua lebih cerah (hover/accent)
const Color kSilver = Color(0xFFECEFF4); // abu muda (background)
const Color kSilverDark = Color(
  0xFFCFD8DC,
); // abu sedikit lebih gelap (border/card)
const Color kWhite = Color(0xFFFFFFFF);
const Color kTextDim = Color(0xFF90A4AE); // abu untuk teks sekunder
// ─────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum Kamera & Notifikasi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kNavy,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kSilver,
        appBarTheme: const AppBarTheme(
          backgroundColor: kNavy,
          foregroundColor: kWhite,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotification();
  }

  // 1. Inisialisasi notifikasi
  Future<void> _initNotification() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(initSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 2. Tampilkan notifikasi lokal
  Future<void> _showNotification(String source) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id_foto',
          'Notifikasi Foto',
          channelDescription: 'Notifikasi saat berhasil mengambil/memilih foto',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0,
      'Foto Berhasil Dimuat! 📸',
      'Kamu baru saja memilih foto melalui $source.',
      notifDetails,
    );
  }

  // 3. Ambil gambar dari kamera / galeri
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final String sourceText = source == ImageSource.camera
          ? 'Kamera'
          : 'Galeri';
      await _showNotification(sourceText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum Perangkat Keras'),
        // Garis bawah tipis berwarna biru cerah sebagai aksen
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: kNavyLight),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Area Gambar ──────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kSilverDark, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: kNavy.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.contain)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 72,
                            color: kSilverDark,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada foto yang dipilih',
                            style: TextStyle(
                              color: kTextDim,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gunakan tombol di bawah untuk memulai',
                            style: TextStyle(color: kTextDim, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Kamera ────────────────────────────────
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text(
                'Buka Kamera',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: kWhite,
              ),
            ),

            const SizedBox(height: 12),

            // ── Tombol Galeri ────────────────────────────────
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text(
                'Pilih dari Galeri',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSilverDark,
                foregroundColor: kNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
