<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br>APLIKASI BERBASIS PLATFORM</h1>
  <br />
  <h3>TUGAS MODUL 08 & 09 <br> NOTIFIKASI & API PERANGKAT KERAS <br>(Aplikasi Kamera & Notifikasi)</h3>
  <br />
  <br />
  <img src="assets/logo.png" alt="Logo" width="300"> 
  <br />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Kanasya Abdi Aziz</strong><br>
    <strong>2311102140</strong><br>
    <strong>S1 IF-11-01</strong>
  </p>
  <br />
  <br />
  <h3>Dosen Pengampu :</h3>
  <p>
    <strong>Dimas Fanny Hebrasianto Permadi, S.ST., M.Kom</strong>
  </p>
  <br />
  <br />
    <h4>Asisten Praktikum :</h4>
    <strong> Apri Pandu Wicaksono </strong> <br>
    <strong>Rangga Pradarrell Fathi</strong>
  <br />
  <h3>LABORATORIUM HIGH PERFORMANCE
 <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026</h3>
</div>

---

## Dasar Teori

Flutter adalah framework multiplatform, pengembang dapat membuat aplikasi desktop, web, Android, dan iOS hanya dengan satu basis kode. Aplikasi "Camera & Notification App" dibuat dalam praktikum Modul 8-9 ini. Aplikasi ini memiliki dua fitur utama: mengambil foto menggunakan kamera atau galeri serta menampilkan notifikasi lokal setelah foto diambil dengan benar.

### Camera & Image Picker

Flutter tidak memiliki akses kamera secara bawaan, paket tambahan yang disebut "image_picker" diperlukan. Aplikasi dalam paket ini dapat mengambil foto langsung dari kamera perangkat dan memilih foto dari galeri. Dengan menggunakan metode "pickImage()", pengambilan foto dilakukan menggunakan "ImagePicker", yang menerima parameter "source". Nilai "ImageSource.camera" digunakan untuk membuka kamera, dan "ImageSource.gallery" digunakan untuk membuka galeri. Objekte "XFile?" yang dihasilkan oleh "pickImage()" kemudian diubah menjadi "File" dari paket "dart:io" sehingga dapat ditampilkan menggunakan widget "Image.file".

### Local Notification

Paket "flutter_local_notifications" digunakan untuk mengimplementasikan notifikasi lokal Flutter. Paket ini memungkinkan aplikasi untuk menampilkan notifikasi sistem di perangkat Android dan iOS tanpa memerlukan koneksi internet atau server. Sebelum notifikasi dapat digunakan, plugin harus diinisialisasi menggunakan "FlutterLocalNotificationsPlugin" dengan pengaturan "AndroidInitializationSettings". Ini dilakukan di dalam fungsi "main()" sebelum memanggil "runApp()" untuk memastikan plugin siap digunakan sebelum aplikasi berjalan. Metode "show()" digunakan untuk menampilkan notifikasi, yang menerima parameter ID notifikasi, judul, isi pesan, dan detail notifikasi dalam format "NotificationDetails."

### StatefulWidget dan setState

Tampilan aplikasi harus diperbarui ketika foto dipilih, menampilkan foto yang baru diambil, halaman utama menggunakan "StatefulWidget". Setiap kali foto dipilih, variabel "imageFile" diperbarui menggunakan "setState()", sehingga widget "Image.file" otomatis merender ulang tampilan dengan foto terbaru.

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.7
  flutter_local_notifications: ^17.0.0
  permission_handler: ^11.3.0
```

---

## Konfigurasi Android

### `android/app/build.gradle.kts`

```gradle
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_application_1"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

---

## Source Code (`lib/main.dart`)

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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

  // Menggunakan inisialisasi plugin yang aman untuk compile
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotification();
  }

  // 1. Inisialisasi Fitur Notifikasi dengan Sintaks Named Argument yang Benar
  Future<void> _initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Mencegah error positional arguments dengan named argument
    await _localNotificationsPlugin.initialize(initializationSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 2. Fungsi Memicu Notifikasi Lokal dengan Named Argument Lengkap
  Future<void> _showNotification(String source) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'channel_id_foto',
          'Notifikasi Foto',
          channelDescription: 'Notifikasi saat berhasil mengambil/memilih foto',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      0,
      'Foto Berhasil Dimuat! 📸',
      'Kamu baru saja memilih foto melalui $source.',
      platformChannelSpecifics,
    );
  }

  // 3. Fungsi Mengambil Gambar (Kamera atau Galeri)
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      String sourceText = source == ImageSource.camera ? 'Kamera' : 'Galeri';
      _showNotification(sourceText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum Perangkat Keras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.contain),
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 80, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada foto yang dipilih',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Buka Kamera Langsung'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih Foto dari Galeri'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Penjelasan Singkat Tiap Widget

**`MyApp` (StatelessWidget)** Widget ini merupakan akar (*root*) dari seluruh aplikasi yang berfungsi untuk mengatur konfigurasi global. Di dalam widget ini, `MaterialApp` digunakan untuk menentukan judul aplikasi, menyembunyikan *banner* debug, serta mengatur tema visual dasar aplikasi seperti warna primer biru dan mengaktifkan panduan desain Material 3. `MyApp` juga bertugas mengarahkan tampilan awal aplikasi langsung ke halaman `HomeScreen`.

**`HomeScreen` (StatefulWidget)** Widget ini mendefinisikan halaman utama aplikasi yang sifatnya dinamis atau dapat berubah statusnya (*stateful*). Karena aplikasi ini melibatkan interaksi langsung dengan perangkat keras—seperti menangkap file gambar baru dan memicu siklus inisialisasi sistem notifikasi saat aplikasi pertama kali dibuka—`HomeScreen` memisahkan strukturnya ke dalam kelas `_HomeScreenState` untuk mengelola perubahan data tersebut secara langsung di layar.

**`Scaffold` dan `AppBar**` `Scaffold` adalah widget struktur dasar yang menyediakan kerangka tata letak visual utama untuk halaman Android atau iOS. Di bagian atasnya terdapat widget `AppBar` yang berfungsi sebagai bilah menu atau *header* aplikasi, menampilkan judul teks "Praktikum Perangkat Keras" dengan latar belakang warna biru yang konsisten untuk mempertegas identitas visual halaman.

**`Padding` dan `Column**` Widget `Padding` membungkus seluruh konten utama di dalam halaman untuk memberikan jarak pembatas (*margin*) yang rapi di semua sisi sebesar 16 piksel. Di dalamnya, terdapat widget `Column` yang berfungsi untuk menyusun widget-widget anak secara vertikal dari atas ke bawah, sekaligus mengatur penyebaran kontennya agar meregang secara horizontal memenuhi lebar layar.

**`Expanded` dan `Center**` Widget `Expanded` digunakan di dalam `Column` untuk memaksa area tampilan gambar mengambil sisa ruang kosong yang tersedia secara maksimal di layar. Di dalam area luas tersebut, widget `Center` diletakkan untuk memastikan bahwa komponen visual berikutnya—baik berupa kotak penampung kosong maupun gambar asli yang berhasil dimuat—selalu berada tepat di tengah-tengah area porsi layar tersebut.

**Kondisional `ClipRRect` / `Container` (Tempat Gambar)** Bagian ini menggunakan logika kondisional untuk menampilkan komponen yang berbeda tergantung status file gambar. Jika gambar sudah dipilih, `ClipRRect` akan memotong ujung-ujung objek `Image.file` agar melengkung rapi; namun jika gambar masih kosong, aplikasi akan menampilkan widget `Container` abu-abu yang dihiasi dengan ikon galeri standar dan teks bertuliskan "Belum ada foto yang dipilih".

**`ElevatedButton.icon` (Tombol Kamera & Galeri)** Dua widget tombol timbul ini diletakkan di bagian bawah halaman untuk memicu aksi interaksi pengguna secara langsung. Tombol pertama dirancang khusus dengan latar biru solid dan ikon kamera untuk membuka fitur kamera bawaan perangkat keras, sedangkan tombol kedua menggunakan latar biru muda yang lebih lembut dengan ikon pustaka foto untuk membuka media galeri penyimpanan ponsel.

## Tampilan

### 1. Tampilan Awal (Belum Ada Foto)

![Tampilan Awal](assets/1.jpg)

### 2. Tampilan Setelah Foto Dengan Kamera

![Foto dari Kamera](assets/2.jpg)

### 3. Notifikasi Setelah Foto Berhasil Dipilih

![Notifikasi](assets/3.jpg)

### 4. Tampilan Setelah Foto Dari Galeri

![Foto dari Galeri](assets/4.jpg)
---
## Kesimpulan

Berdasarkan hasil pembuatan dan pengujian aplikasi "Praktikum Perangkat Keras" berbasis Flutter, dapat disimpulkan bahwa integrasi fitur kamera dan galeri penyimpanan menggunakan package image_picker telah berhasil dilakukan dengan baik, sehingga pengguna dapat mengambil atau memilih gambar tanpa kendala teknis. Selain itu, sistem notifikasi lokal melalui package flutter_local_notifications terbukti mampu merespons aksi pengguna secara instan dengan memicu pemberitahuan tepat setelah gambar berhasil dimuat. Keberhasilan ini juga didukung oleh penerapan StatefulWidget yang secara dinamis memperbarui tampilan antarmuka (UI) secara otomatis saat terjadi perubahan data gambar, serta didukung oleh struktur tata letak yang rapi dan ergonomis sesuai dengan standar desain Material 3.