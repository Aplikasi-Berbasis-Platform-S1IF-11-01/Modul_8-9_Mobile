<div align="center">
  <br />

  <h1>LAPORAN PRAKTIKUM <br>
  APLIKASI BERBASIS PLATFORM
  </h1>

  <br />

  <h3>MODUL 8 & 9<br>
  MOBILE
  </h3>

  <br />

  <img width="350" height="350" alt="logo" src="https://github.com/user-attachments/assets/22ae9b17-5e73-48a6-b5dd-281e6c70613e" />



  <br />
  <br />
  <br />

  <h3>Disusun Oleh :</h3>

  <p>
    <strong>Boutefhika Nuha Ziyadatul Khair</strong><br>
    <strong>2311102316</strong><br>
    <strong>S1 IF-11-01</strong>
  </p>

  <br />

  <h3>Dosen Pengampu :</h3>

  <p>
    <strong>Dimas Fanny Hebrasianto Permadi, S.ST., M.Kom</strong>
  </p>
  
  <br />
  <br />
    <h4>Asisten Praktikum :</h4>
    <strong>Apri Pandu Wicaksono </strong> <br>
    <strong>Rangga Pradarrell Fathi</strong>
  <br />

  <h3>LABORATORIUM HIGH PERFORMANCE
 <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026</h3>
</div>

<hr>


## Dasar Teori

### 1. Camera API & image_picker

**image_picker** adalah plugin Flutter resmi yang menyediakan akses ke:
- **Kamera** (`ImageSource.camera`): Membuka antarmuka kamera perangkat langsung untuk mengambil foto baru
- **Galeri** (`ImageSource.gallery`): Membuka file picker sistem untuk memilih foto dari penyimpanan

Plugin ini mengembalikan objek `XFile` yang berisi path file foto yang dipilih/diambil.

```
final XFile? photo = await _picker.pickImage(
  source: ImageSource.camera,  // atau ImageSource.gallery
  imageQuality: 85,            // kompresi 0-100
);
```

### 2. flutter_local_notifications

Plugin ini memungkinkan aplikasi menampilkan **notifikasi lokal** (tidak memerlukan koneksi internet atau server) pada perangkat Android dan iOS.

Alur kerja notifikasi:
1. **Inisialisasi** plugin dengan pengaturan platform (Android/iOS)
2. **Buat channel** notifikasi (Android 8.0+)
3. **Tampilkan** notifikasi dengan `flutterLocalNotificationsPlugin.show()`

Komponen utama:
- `AndroidNotificationDetails`: Konfigurasi tampilan notifikasi di Android (channel ID, icon, priority, sound)
- `DarwinNotificationDetails`: Konfigurasi untuk iOS/macOS
- `NotificationDetails`: Wrapper yang menggabungkan konfigurasi semua platform


### 3. Permissions (Izin Aplikasi)

Aplikasi mobile memerlukan izin eksplisit dari pengguna sebelum mengakses hardware atau data sensitif. Izin yang dibutuhkan aplikasi ini:

| Izin | Platform | Kegunaan |
|---|---|---|
| `CAMERA` | Android | Akses kamera untuk foto |
| `READ_MEDIA_IMAGES` | Android 13+ | Baca foto dari galeri |
| `READ_EXTERNAL_STORAGE` | Android ≤12 | Baca file dari penyimpanan |
| `POST_NOTIFICATIONS` | Android 13+ | Tampilkan notifikasi |
| `NSCameraUsageDescription` | iOS | Akses kamera |
| `NSPhotoLibraryUsageDescription` | iOS | Akses galeri |


### 4. Asynchronous Programming

Flutter menggunakan model asynchronous untuk operasi yang membutuhkan waktu (I/O, kamera):

```dart
// async: menandai fungsi sebagai asynchronous
Future<void> _takePhoto() async {
  // await: tunggu sampai operasi selesai sebelum lanjut
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
}
```

`Future<T>` merepresentasikan nilai yang akan tersedia di masa depan. `async/await` membuat kode asynchronous terlihat seperti kode sinkronus.

## Penjelasan Singkat Tiap Widget

### Widget Struktural (Kerangka Halaman)

| Widget | Penjelasan |
|---|---|
| **`MaterialApp`** | Widget root aplikasi. Menyediakan tema Material Design, navigasi, dan konfigurasi global seperti judul aplikasi dan `debugShowCheckedModeBanner`. |
| **`Scaffold`** | Kerangka halaman standar Material. Menyediakan slot untuk `AppBar`, `body`, `FloatingActionButton`, `SnackBar`, dan lain-lain. |
| **`AppBar`** | Bar navigasi di bagian atas layar. Menampilkan judul, ikon, dan aksi. Diatur dengan `backgroundColor` dan `foregroundColor`. |

### Widget Layout (Tata Letak)

| Widget | Penjelasan |
|---|---|
| **`Column`** | Menyusun widget secara vertikal (dari atas ke bawah). Properti `crossAxisAlignment` mengatur perataan horizontal child-nya. |
| **`Row`** | Menyusun widget secara horizontal (dari kiri ke kanan). Digunakan untuk menampilkan ikon dan teks berdampingan di AppBar. |
| **`SingleChildScrollView`** | Membungkus konten agar bisa di-scroll ketika konten melebihi ukuran layar. Penting untuk halaman dengan konten panjang. |
| **`Stack`** | Menumpuk widget satu di atas yang lain. Digunakan untuk menempatkan badge "Foto Dipilih" di atas foto. |
| **`Positioned`** | Digunakan di dalam `Stack` untuk menempatkan widget di posisi spesifik (pojok, tepi, dll). |
| **`SizedBox`** | Membuat ruang kosong dengan lebar/tinggi tertentu. Berfungsi sebagai *spacer* antar widget. |
| **`Padding`** | Menambahkan jarak (padding) di sekeliling widget anaknya. |
| **`Expanded`** | Membuat widget mengisi sisa ruang yang tersedia dalam `Row` atau `Column`. |

### Widget Tampilan (Visual)

| Widget | Penjelasan |
|---|---|
| **`Text`** | Menampilkan teks statis. Mendukung kustomisasi via `TextStyle` (ukuran, warna, ketebalan font). |
| **`Icon`** | Menampilkan ikon dari library Material Icons bawaan Flutter. |
| **`Image.file`** | Menampilkan gambar dari file lokal di perangkat. Digunakan untuk menampilkan foto yang telah diambil/dipilih. |
| **`Container`** | Widget serbaguna untuk dekorasi (warna background, border, border radius, shadow) dan pengaturan ukuran. |
| **`CircularProgressIndicator`** | Menampilkan animasi loading lingkaran berputar. Ditampilkan saat proses mengambil foto berlangsung. |

### Widget Interaksi (Input)

| Widget | Penjelasan |
|---|---|
| **`ElevatedButton.icon`** | Tombol dengan latar belakang berwarna dan ikon. Dua tombol utama: "Buka Kamera" (biru) dan "Pilih dari Galeri" (hijau). |
| **`SnackBar`** | Pesan singkat yang muncul di bagian bawah layar sementara. Digunakan untuk konfirmasi sukses atau error. |

### Widget State Management

| Widget | Penjelasan |
|---|---|
| **`StatefulWidget`** | Base class untuk widget yang bisa berubah state-nya. `HomePage` extends ini karena perlu memperbarui tampilan foto. |
| **`StatelessWidget`** | Base class untuk widget tanpa state. `MyApp` extends ini karena hanya mendefinisikan konfigurasi app yang tidak berubah. |
| **`setState()`** | Method untuk memberitahu Flutter bahwa state telah berubah, sehingga widget perlu di-render ulang (*rebuild*). |

### Plugin & Kelas Pendukung

| Kelas/Plugin | Penjelasan |
|---|---|
| **`ImagePicker`** | Kelas dari plugin `image_picker`. Method `pickImage()` membuka kamera atau galeri dan mengembalikan `XFile`. |
| **`XFile`** | Representasi file lintas platform. Menyimpan path file foto yang dipilih. |
| **`File`** (dart:io) | Kelas Dart untuk operasi file sistem. Digunakan mengonversi path `XFile` menjadi objek gambar yang bisa ditampilkan `Image.file`. |
| **`FlutterLocalNotificationsPlugin`** | Kelas utama plugin notifikasi. Method `show()` menampilkan notifikasi dengan ID, judul, pesan, dan detail platform. |
| **`AndroidNotificationDetails`** | Konfigurasi notifikasi spesifik Android: channel ID, nama channel, importance, priority, dan ikon. |
| **`DarwinNotificationDetails`** | Konfigurasi notifikasi spesifik iOS/macOS: izin alert, badge, dan sound. |
| **`NotificationDetails`** | Wrapper yang menggabungkan konfigurasi Android dan iOS menjadi satu objek untuk semua platform. |

## 📦 Dependencies

```
image_picker: ^1.0.7
└── Akses kamera & galeri foto perangkat

flutter_local_notifications: ^17.0.0
└── Notifikasi lokal tanpa server/internet
```


## 📱 Screenshot Hasil

### Tampilan Utama (Sebelum Foto Dipilih)



### Tampilan Setelah Foto Dipilih


### Tampilan Notifikasi


## 💻 Source Code

### `pubspec.yaml`

```
name: foto_notifikasi_app
description: Aplikasi Flutter untuk mengambil foto dan menampilkan notifikasi lokal.

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.7            # Plugin kamera & galeri
  flutter_local_notifications: ^17.0.0  # Plugin notifikasi lokal
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### `AndroidManifest.xml` (Izin Android)

```
```

---

### `main.dart` — Kode Lengkap

```

```

## 📱 Screenshot Hasil

### Tampilan Awal


### Tampilan Foto Ambil dari Kamera


### Hasil & Notifikasi


### Tampilan Foto dari ampil dari Galeri


### Hasil & Notifikasi

