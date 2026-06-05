<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br>APLIKASI BERBASIS PLATFORM</h1>
  <br />
  <h3>MODUL 8-9 - Mobile <br> Flutter Data Mahasiswa </h3>
  <br />
  <img src="assets\logo.jpeg" alt="Logo" width="300"> 
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Raihan Ramadhan</strong><br>
    <strong>2311102040</strong><br>
    <strong>IF-11-REG01</strong>
  </p>
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

## 1. Dasar Teori

### 1.1 Flutter

Flutter adalah framework UI open-source dari Google yang digunakan untuk membangun aplikasi mobile (Android & iOS) menggunakan bahasa Dart. Flutter menerapkan konsep **widget** sebagai komponen utama untuk membangun tampilan yang responsif dan atraktif. Semua elemen UI di Flutter — dari tombol, teks, hingga tata letak — adalah widget.

### 1.2 Image Picker

`image_picker` adalah plugin Flutter resmi yang menyediakan antarmuka untuk berinteraksi dengan API sistem operasi guna memilih gambar dari galeri perangkat atau mengambil foto baru secara langsung menggunakan kamera. Plugin ini mendukung Android dan iOS secara native.

### 1.3 Flutter Local Notifications

`flutter_local_notifications` adalah plugin yang digunakan untuk membuat dan menampilkan notifikasi pop-up lokal pada perangkat tanpa memerlukan koneksi internet atau server. Berbeda dengan notifikasi push (seperti Firebase Cloud Messaging), notifikasi lokal dipicu langsung dari dalam kode aplikasi itu sendiri dan bekerja secara *offline*.

### 1.4 StatefulWidget

Aplikasi ini menggunakan **StatefulWidget** karena memerlukan perubahan *state* dinamis — yaitu saat pengguna mengambil atau memilih foto, UI harus di-*rebuild* untuk menampilkan gambar baru. Metode `setState()` digunakan untuk memperbarui variabel `_imageFile` dan memicu proses render ulang tampilan.

### 1.5 Widget yang Digunakan

Aplikasi ini memanfaatkan beberapa widget utama Flutter:

| Widget | Fungsi |
|---|---|
| `Scaffold` | Kerangka dasar visual halaman (AppBar + body) |
| `AppBar` | Bilah judul di bagian atas layar |
| `Column` | Menyusun widget secara vertikal |
| `Row` | Menyusun widget secara horizontal |
| `Container` | Mengelola dekorasi UI (warna, border, border radius) |
| `Image.file` | Menampilkan gambar dari file sistem lokal perangkat |
| `ElevatedButton` | Tombol berdesain modern dengan efek bayangan |
| `OutlinedButton` | Tombol dengan garis tepi tanpa latar belakang |
| `ClipRRect` | Memotong widget dengan sudut membulat (rounded corner) |
| `Padding` | Memberikan jarak di sekeliling konten |
| `SizedBox` | Memberikan spasi kosong antar-widget |

---

## 2. Implementasi Program

### 2.1 Deskripsi Aplikasi

Aplikasi bertema **"Notifikasi & API Perangkat Keras"** ini dibuat untuk memahami cara mengakses fungsionalitas hardware dan layanan sistem operasi melalui Flutter. Fitur utama yang diimplementasikan:

1. **Ambil Foto (Kamera)** — Tombol "Kamera" membuka kamera perangkat secara langsung untuk mengambil foto baru.
2. **Pilih Foto (Galeri)** — Tombol "Galeri" membuka galeri foto perangkat untuk memilih gambar yang sudah ada.
3. **Penampil Gambar** — Foto yang berhasil diambil atau dipilih langsung ditampilkan pada area preview di tengah halaman.
4. **Notifikasi Lokal** — Setelah gambar berhasil diperoleh, notifikasi pop-up muncul dari *system tray* HP yang menginformasikan asal gambar (dari kamera atau galeri).

### 2.2 Alur Kerja Aplikasi

1. Pengguna menekan tombol **Kamera** atau **Galeri**.
2. Plugin `ImagePicker` membuka antarmuka kamera/galeri bawaan OS.
3. Pengguna memilih atau mengambil foto → `XFile` dikembalikan oleh plugin.
4. `setState()` dipanggil → variabel `_imageFile` diperbarui → UI ter-*rebuild*.
5. Foto tampil di area preview, dan status *"Foto berhasil dimuat!"* muncul.
6. `flutterLocalNotificationsPlugin.show()` dipanggil → notifikasi pop-up ditampilkan oleh sistem Android.

---

## 3. Source Code & Penjelasan

### 3.1 `pubspec.yaml` — Konfigurasi Dependensi

File ini adalah file konfigurasi utama proyek Flutter yang mendefinisikan nama aplikasi, versi, serta daftar *package* (library) pihak ketiga yang dibutuhkan.

```yaml
name: foto_app
description: Aplikasi Flutter untuk mengambil foto dan menampilkan notifikasi lokal.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Package untuk memilih gambar dari kamera atau galeri
  image_picker: ^1.0.7

  # Package untuk menampilkan notifikasi lokal di perangkat
  flutter_local_notifications: ^17.1.2

  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

**Penjelasan:**
- `image_picker: ^1.0.7` — menjadi jembatan antara aplikasi Flutter dengan antarmuka kamera/galeri bawaan Android/iOS.
- `flutter_local_notifications: ^17.1.2` — digunakan untuk membangun dan menampilkan notifikasi di *notification tray* HP secara *offline* tanpa server.
- `uses-material-design: true` — mengaktifkan ikon dan komponen Material Design dari Google.

---

### 3.2 `AndroidManifest.xml` — Konfigurasi Izin Akses Android

File ini adalah file konfigurasi utama aplikasi Android yang mendeklarasikan identitas aplikasi, izin akses hardware (*permissions*), dan komponen-komponen penting yang dibutuhkan oleh plugin.

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Izin menggunakan kamera perangkat -->
    <uses-permission android:name="android.permission.CAMERA"/>

    <!-- Izin membaca penyimpanan (untuk galeri, Android < 13) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

    <!-- Izin membaca media gambar (Android 13+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <!-- Izin menampilkan notifikasi (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <!-- Fitur kamera dibutuhkan tapi tidak wajib ada -->
    <uses-feature android:name="android.hardware.camera" android:required="false"/>

    <application
        android:label="Foto App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Dibutuhkan oleh flutter_local_notifications -->
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

**Penjelasan tiap izin:**

| Permission | Penjelasan |
|---|---|
| `CAMERA` | Wajib ada agar aplikasi bisa membuka kamera hardware. Tanpa ini, aplikasi akan *crash* saat tombol kamera ditekan. |
| `READ_EXTERNAL_STORAGE` | Dibutuhkan untuk mengakses galeri foto pada Android versi di bawah 13. |
| `READ_MEDIA_IMAGES` | Pengganti `READ_EXTERNAL_STORAGE` pada Android 13 ke atas (API 33+) yang lebih spesifik dan aman. |
| `POST_NOTIFICATIONS` | Wajib pada Android 13+ agar aplikasi diizinkan mengirim notifikasi pop-up ke pengguna. |

**Penjelasan `<receiver>`:**
Dua buah `<receiver>` di atas didaftarkan khusus untuk kebutuhan plugin `flutter_local_notifications`. `ScheduledNotificationBootReceiver` memungkinkan notifikasi terjadwal tetap berfungsi setelah perangkat di-restart.

---

### 3.3 `main.dart` — Kode Utama Aplikasi

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Inisialisasi plugin notifikasi secara global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // Memastikan Flutter binding sudah siap sebelum menjalankan app
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi inisialisasi untuk Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Konfigurasi inisialisasi gabungan (Android + iOS)
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // Menginisialisasi plugin notifikasi
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}
```

**Penjelasan blok `main()`:**
- `WidgetsFlutterBinding.ensureInitialized()` — wajib dipanggil sebelum operasi *async* apa pun di `main()`. Ini memastikan mesin Flutter sudah siap menerima perintah sebelum plugin diinisialisasi.
- `AndroidInitializationSettings('@mipmap/ic_launcher')` — menentukan ikon yang muncul di samping notifikasi, yaitu ikon default aplikasi Flutter.
- `flutterLocalNotificationsPlugin.initialize()` — mendaftarkan plugin notifikasi ke sistem operasi Android agar siap digunakan.

---

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: widget root untuk aplikasi Material Design
    return MaterialApp(
      title: 'Foto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
```

**Penjelasan `MyApp`:**
- `MaterialApp` — widget root yang membungkus seluruh aplikasi dengan konfigurasi tema Material Design 3.
- `debugShowCheckedModeBanner: false` — menyembunyikan banner merah "DEBUG" di pojok kanan atas layar.
- `ColorScheme.fromSeed(seedColor: Colors.blue)` — menghasilkan skema warna Material 3 secara otomatis berbasis warna biru.

---

```dart
class _HomePageState extends State<HomePage> {
  // Menyimpan file foto yang dipilih/diambil
  File? _imageFile;

  // Instance ImagePicker untuk mengakses kamera dan galeri
  final ImagePicker _picker = ImagePicker();
```

**Penjelasan variabel state:**
- `File? _imageFile` — menyimpan referensi file gambar yang dipilih. Bertipe *nullable* (`?`) karena awalnya belum ada foto.
- `ImagePicker _picker` — objek utama dari plugin `image_picker` yang digunakan untuk membuka antarmuka kamera/galeri.

---

```dart
  // Fungsi menampilkan notifikasi lokal
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'foto_channel_id',    // ID channel (harus unik)
      'Foto Notifications', // Nama channel
      channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Menampilkan notifikasi dengan ID 0
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
```

**Penjelasan `_showNotification()`:**
- `AndroidNotificationDetails` — objek konfigurasi khusus Android yang mendefinisikan perilaku notifikasi.
- `'foto_channel_id'` — ID unik untuk *notification channel*. Android 8+ mengharuskan setiap notifikasi memiliki channel tersendiri agar pengguna bisa mengatur preferensinya di pengaturan HP.
- `Importance.max` dan `Priority.high` — kombinasi ini memastikan notifikasi muncul sebagai *Heads-up Notification* (pop-up yang muncul di bagian atas layar), bukan hanya tersimpan diam-diam di notification tray.
- `flutterLocalNotificationsPlugin.show(0, ...)` — angka `0` adalah ID notifikasi. Jika dipanggil lagi dengan ID yang sama, notifikasi lama akan digantikan oleh yang baru.

---

```dart
  // Fungsi mengambil foto menggunakan kamera
  Future<void> _ambilFotoKamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera, // Membuka kamera perangkat
      imageQuality: 80,           // Kualitas gambar 80%
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path); // Menyimpan file foto
      });

      // Tampilkan notifikasi setelah foto berhasil diambil
      await _showNotification(
        '📷 Foto Berhasil Diambil!',
        'Foto dari kamera sudah tersimpan dan ditampilkan.',
      );
    }
  }

  // Fungsi memilih foto dari galeri
  Future<void> _pilihFotoGaleri() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery, // Membuka galeri foto
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path); // Menyimpan file foto
      });

      // Tampilkan notifikasi setelah foto berhasil dipilih
      await _showNotification(
        '🖼️ Foto Berhasil Dipilih!',
        'Foto dari galeri berhasil dimuat ke aplikasi.',
      );
    }
  }
```

**Penjelasan fungsi pengambilan gambar:**
- `_picker.pickImage(source: ImageSource.camera)` — membuka aplikasi kamera bawaan HP. Eksekusi kode di bawah baris ini akan "ditahan" (`await`) hingga pengguna selesai mengambil foto.
- `_picker.pickImage(source: ImageSource.gallery)` — membuka galeri foto bawaan HP.
- `imageQuality: 80` — mengompresi gambar hingga 80% dari kualitas aslinya untuk menghemat memori tanpa penurunan kualitas visual yang signifikan.
- `XFile? photo` — hasil kembalian berupa objek `XFile` yang berisi path file sementara foto. Jika pengguna membatalkan (menekan *back*), nilainya akan `null`.
- `setState(() { _imageFile = File(photo.path); })` — mengonversi `XFile` ke `File` dan menyimpannya ke *state*. Pemanggilan `setState()` memicu Flutter untuk menggambar ulang UI sehingga foto langsung tampil.

---

```dart
  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman (AppBar + body)
    return Scaffold(
      appBar: AppBar(
        // AppBar: bilah judul di bagian atas layar
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Foto App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
      ),
```

**Penjelasan `AppBar`:**
- `Scaffold` — widget fondasi yang menyediakan struktur halaman standar Material Design (AppBar, body, FAB, drawer, dll.).
- `AppBar` — bilah navigasi di bagian atas. Di dalamnya digunakan `Row` untuk menampilkan ikon kamera dan teks judul secara berdampingan.
- `SizedBox(width: 8)` — memberikan jarak horizontal 8 piksel antara ikon dan teks.

---

```dart
      body: Padding(
        // Padding: memberikan jarak di sekeliling konten
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Column: menyusun widget secara vertikal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container: kotak untuk menampilkan preview foto
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      // ClipRRect: memotong gambar dengan sudut membulat
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        // Image.file: menampilkan gambar dari file lokal
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Foto akan tampil di sini',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
```

**Penjelasan area preview foto:**
- `Padding` — memberi jarak 20px di seluruh sisi konten agar tidak menempel ke tepi layar.
- `Column` dengan `crossAxisAlignment: CrossAxisAlignment.stretch` — memaksa semua child widget untuk memenuhi lebar penuh kolom.
- `Container` dengan `BoxDecoration` — membuat area preview berupa kotak abu-abu muda dengan border tipis dan sudut membulat (*rounded corner*) 16px.
- **Conditional rendering** (`_imageFile != null ? ... : ...`) — logika ternary yang menentukan apa yang ditampilkan:
  - Jika `_imageFile` berisi data → tampilkan gambar menggunakan `Image.file` di dalam `ClipRRect`.
  - Jika `_imageFile` masih `null` → tampilkan ikon dan teks placeholder.
- `ClipRRect` — memotong gambar agar mengikuti sudut membulat dari `Container`.
- `Image.file(_imageFile!, fit: BoxFit.cover)` — menampilkan gambar dari file lokal perangkat. `BoxFit.cover` memastikan gambar mengisi seluruh area tanpa distorsi.

---

```dart
            const SizedBox(height: 24),

            // Row: menyusun dua tombol secara horizontal
            Row(
              children: [
                // Tombol pertama: Buka Kamera
                Expanded(
                  child: ElevatedButton.icon(
                    // ElevatedButton: tombol dengan efek bayangan
                    onPressed: _ambilFotoKamera,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Kamera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol kedua: Pilih dari Galeri
                Expanded(
                  child: OutlinedButton.icon(
                    // OutlinedButton: tombol dengan garis tepi
                    onPressed: _pilihFotoGaleri,
                    icon: Icon(Icons.photo_library, color: Colors.blue[700]),
                    label: Text(
                      'Galeri',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.blue[700]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
```

**Penjelasan area tombol:**
- `Row` — menyusun dua tombol secara berdampingan horizontal.
- `Expanded` — membuat setiap tombol mengisi setengah lebar layar secara proporsional. Tanpa `Expanded`, tombol akan berukuran sesuai kontennya saja.
- `SizedBox(width: 12)` — memberikan jarak 12px di antara kedua tombol.
- `ElevatedButton.icon` — tombol solid berwarna biru untuk aksi utama (kamera), terdiri dari ikon dan label. Parameter `onPressed: _ambilFotoKamera` menghubungkan tombol ke fungsi pengambilan foto.
- `OutlinedButton.icon` — tombol dengan garis tepi biru tanpa latar belakang untuk aksi sekunder (galeri). Perbedaan visual ini mengikuti panduan Material Design di mana tombol solid = aksi utama, tombol outlined = aksi sekunder.

---

```dart
            const SizedBox(height: 16),

            // Menampilkan keterangan sumber foto jika sudah ada
            if (_imageFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Foto berhasil dimuat!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

**Penjelasan status card:**
- `if (_imageFile != null)` — widget ini hanya dirender jika sudah ada foto yang dimuat. Ini adalah contoh *conditional widget* di Flutter menggunakan sintaks `if` langsung di dalam `children` list.
- `Container` dengan warna hijau muda — menampilkan umpan balik visual (*feedback*) berupa kartu status berwarna hijau yang memberitahu pengguna bahwa foto sudah berhasil dimuat.
- `Icon(Icons.check_circle)` — ikon centang hijau yang memperkuat pesan keberhasilan secara visual.

---

## 4. Hasil
 <img src="assets\hasil.JPG" alt="Logo" width="300"> 
 
## 5. Kesimpulan

Melalui praktikum ini, berhasil dibuat aplikasi Flutter yang memiliki rancangan fitur pengambilan foto dari kamera, pemilihan gambar dari galeri, serta notifikasi lokal. Pengujian aplikasi secara penuh pada perangkat Android belum dapat dilakukan karena keterbatasan ruang penyimpanan dan sumber daya perangkat saat proses build Android. Oleh karena itu, aplikasi hanya berhasil dijalankan pada Flutter Web (Google Chrome) sehingga pengujian yang dapat dilakukan terbatas pada tampilan antarmuka aplikasi. Meskipun demikian, seluruh implementasi kode fitur yang diperlukan telah berhasil dibuat sesuai dengan tujuan praktikum.

1. **Manajemen izin Android** melalui `AndroidManifest.xml` untuk mengakses hardware kamera dan fitur notifikasi.
2. **Penggunaan plugin pihak ketiga** (`image_picker` dan `flutter_local_notifications`) untuk menjembatani kode Dart dengan API native Android.
3. **Reaktivitas UI** menggunakan `StatefulWidget` dan `setState()` agar tampilan otomatis diperbarui saat data berubah.
4. **Notifikasi lokal** dengan konfigurasi channel yang benar agar notifikasi muncul sebagai *Heads-up Notification* di Android 8+.
5. **Conditional rendering** untuk menampilkan konten berbeda berdasarkan kondisi state (ada foto atau belum).