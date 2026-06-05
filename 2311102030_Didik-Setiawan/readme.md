

<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br>Aplikasi-Berbasis-Platform
</h1>
  <br />
  <h3>MODUL 08-09 - Mobile
 <br> CAMERA & NOTIFICATION APP</h3>
  <br />
  <img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2F1.bp.blogspot.com%2F-vb7jyBjK-sM%2FXXfKp51LrjI%2FAAAAAAAACts%2FEjcXzlgZwSswNWXsBHMyX-6aav1mjA77QCPcBGAYYCw%2Fs1600%2FLogo_Telkom_University_potrait.png&f=1&nofb=1&ipt=9d030d54102ea96369d39fe491220e0536195abc8ee443279c1a420302206400" alt="Logo Telkom" width="300"> 
  <br /><br /><br />
  
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Didik Setiawan</strong><br>
    <strong>2311102030</strong><br>
    <strong>IF-11-REG-01</strong>
  </p>
  <br />
  
  <h3>Dosen Pengampu :</h3>
  <p><strong>Dimas Fanny Hebrasianto Permadi, S.ST., M.Kom</strong></p>
  <br />
  
  <h4>Asisten Praktikum :</h4>
  <strong>Apri Pandu Wicaksono</strong> <br>
  <strong>Rangga Pradarrell Fathi</strong>
  <br />
  
  <h3>LABORATORIUM HIGH PERFORMANCE<br>FAKULTAS INFORMATIKA<br>UNIVERSITAS TELKOM PURWOKERTO<br>2026</h3>
</div>

---

## DASAR TEORI

Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi lintas platform menggunakan satu basis kode. Flutter memanfaatkan bahasa pemrograman Dart dan menyediakan berbagai widget yang memudahkan pengembangan antarmuka pengguna yang interaktif dan responsif.

Pada praktikum ini, Flutter digunakan untuk mengimplementasikan fitur akses kamera perangkat, pemilihan gambar dari galeri, serta pengiriman notifikasi lokal ketika pengguna berhasil mengambil atau memilih foto. Fitur-fitur tersebut memanfaatkan package tambahan seperti Camera, Image Picker, dan Flutter Local Notifications.

---

# Fitur Aplikasi

* Mengakses kamera perangkat
* Mengambil foto secara langsung menggunakan kamera
* Memilih gambar dari galeri perangkat
* Menampilkan hasil foto atau gambar pada halaman utama
* Menampilkan notifikasi lokal setelah foto berhasil dipilih atau diambil
* Navigasi antar halaman menggunakan Navigator
* Tampilan berbasis Material Design 3
* Preview kamera secara real-time
* Penanganan error saat kamera atau galeri tidak dapat diakses

---

# Package yang Digunakan

Tambahkan dependency berikut pada file `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  camera: ^0.11.0
  image_picker: ^1.1.2
  flutter_local_notifications: ^19.0.0
```

---

# Penjelasan Source Code

## 1. Import Package

```dart
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
```

Digunakan untuk mengakses fitur kamera, galeri, notifikasi lokal, serta manipulasi data gambar dalam bentuk byte.

---

## 2. Fungsi Main

```dart
Future<void> main() async
```

Merupakan fungsi pertama yang dijalankan saat aplikasi dibuka.

Pada fungsi ini dilakukan:

* Inisialisasi Flutter Binding
* Pencarian kamera yang tersedia
* Inisialisasi layanan notifikasi lokal
* Menjalankan aplikasi menggunakan widget MyApp

---

## 3. WidgetsFlutterBinding

```dart
WidgetsFlutterBinding.ensureInitialized();
```

Digunakan untuk memastikan seluruh layanan Flutter telah siap sebelum memanggil operasi asynchronous.

---

## 4. Available Cameras

```dart
availableCameras();
```

Digunakan untuk mendapatkan daftar kamera yang tersedia pada perangkat.

---

## 5. Local Notification Service

```dart
await LocalNotificationService.instance.init();
```

Berfungsi menginisialisasi sistem notifikasi lokal sebelum aplikasi digunakan.

---

## 6. Class MyApp

```dart
class MyApp extends StatelessWidget
```

Merupakan widget utama aplikasi yang bertugas mengatur:

* Tema aplikasi
* Warna utama
* Halaman awal
* Konfigurasi Material Design 3

---

## 7. MaterialApp

```dart
MaterialApp(
```

Widget utama Flutter yang digunakan untuk:

* Mengatur tema aplikasi
* Menentukan halaman pertama
* Menonaktifkan banner debug

---

## 8. ThemeData

```dart
ThemeData(
```

Digunakan untuk menentukan tampilan global aplikasi.

Tema menggunakan:

* Material Design 3
* Warna utama Teal

---

## 9. HomePage

```dart
class HomePage extends StatefulWidget
```

Merupakan halaman utama aplikasi yang digunakan untuk:

* Membuka kamera
* Memilih gambar dari galeri
* Menampilkan gambar yang dipilih

---

## 10. ImagePicker

```dart
final ImagePicker _picker = ImagePicker();
```

Digunakan untuk mengakses galeri perangkat dan memilih gambar.

---

## 11. Variabel Penyimpanan Gambar

```dart
Uint8List? _selectedImageBytes;
```

Digunakan untuk menyimpan data gambar yang dipilih atau diambil sehingga dapat ditampilkan pada layar.

---

## 12. Memilih Gambar dari Galeri

```dart
_pickFromGallery()
```

Berfungsi untuk:

* Membuka galeri perangkat
* Memilih gambar
* Membaca file gambar
* Menampilkan gambar pada halaman utama

---

## 13. Mengambil Foto dengan Kamera

```dart
_captureWithCamera()
```

Digunakan untuk membuka halaman kamera dan mengambil foto secara langsung.

---

## 14. Navigator Push

```dart
Navigator.of(context).push()
```

Digunakan untuk berpindah dari halaman utama ke halaman kamera.

---

## 15. Menampilkan SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar()
```

Menampilkan pesan informasi apabila terjadi kesalahan saat mengakses kamera atau galeri.

---

## 16. setState()

```dart
setState(() {
```

Digunakan untuk memperbarui tampilan setelah gambar berhasil dipilih atau diambil.

---

## 17. Menampilkan Gambar

```dart
Image.memory(
```

Digunakan untuk menampilkan gambar yang telah dibaca dalam bentuk byte.

---

## 18. CameraCapturePage

```dart
class CameraCapturePage extends StatefulWidget
```

Halaman khusus yang digunakan untuk mengakses kamera perangkat.

---

## 19. CameraController

```dart
CameraController(
```

Digunakan untuk mengontrol kamera seperti:

* Inisialisasi kamera
* Menampilkan preview
* Mengambil foto

---

## 20. Inisialisasi Kamera

```dart
_initializeControllerFuture
```

Digunakan untuk memastikan kamera telah siap digunakan sebelum preview ditampilkan.

---

## 21. CameraPreview

```dart
CameraPreview(
```

Menampilkan tampilan kamera secara langsung pada layar.

---

## 22. Mengambil Foto

```dart
_takePicture()
```

Berfungsi untuk:

* Mengambil gambar menggunakan kamera
* Menyimpan hasil foto
* Mengirim hasil ke halaman sebelumnya

---

## 23. FloatingActionButton

```dart
FloatingActionButton(
```

Digunakan sebagai tombol shutter untuk mengambil foto.

---

## 24. FutureBuilder

```dart
FutureBuilder<void>(
```

Digunakan untuk menunggu proses inisialisasi kamera selesai.

---

## 25. Dispose

```dart
@override
void dispose()
```

Membersihkan CameraController ketika halaman kamera ditutup agar penggunaan memori tetap optimal.

---

# Notifikasi Lokal

## 26. LocalNotificationService

```dart
class LocalNotificationService
```

Class yang digunakan untuk mengelola seluruh fitur notifikasi lokal.

---

## 27. FlutterLocalNotificationsPlugin

```dart
FlutterLocalNotificationsPlugin
```

Digunakan untuk mengirim notifikasi ke perangkat Android maupun iOS.

---

## 28. Inisialisasi Notifikasi

```dart
_plugin.initialize()
```

Mengaktifkan sistem notifikasi pada aplikasi.

---

## 29. Request Permission

```dart
requestNotificationsPermission()
```

Digunakan untuk meminta izin notifikasi kepada pengguna.

---

## 30. Menampilkan Notifikasi

```dart
showPhotoSuccessNotification()
```

Akan dijalankan ketika pengguna berhasil mengambil atau memilih foto.

Isi notifikasi:

```text
Foto Berhasil
Foto sudah siap ditampilkan di halaman utama.
```

---

# Tampilan Aplikasi

## Halaman Utama

* Tombol Buka Kamera
* Tombol Pilih Galeri
* Area Preview Gambar
* AppBar

## Halaman Kamera

* Preview Kamera
* Tombol Ambil Foto
* Navigasi Kembali

## Notifikasi

* Notifikasi muncul setelah foto berhasil dipilih atau diambil

---

# Screenshot

 ![Alt 1](https://raw.githubusercontent.com/didiksetia1/asset/refs/heads/main/WhatsApp%20Image%202026-06-02%20at%2020.46.13%20(1).jpeg)

 ![Alt 1](https://raw.githubusercontent.com/didiksetia1/asset/refs/heads/main/WhatsApp%20Image%202026-06-02%20at%2020.46.14.jpeg)


![Alt 1](https://raw.githubusercontent.com/didiksetia1/asset/refs/heads/main/WhatsApp%20Image%202026-06-02%20at%2020.46.13.jpeg)



---

# Teknologi yang Digunakan

* Flutter
* Dart
* Camera Package
* Image Picker
* Flutter Local Notifications
* Material Design 3

---

# Kesimpulan

Pada praktikum Modul 8–9 berhasil dibuat aplikasi Flutter yang mampu mengakses kamera perangkat, memilih gambar dari galeri, menampilkan hasil gambar pada aplikasi, serta memberikan notifikasi lokal ketika proses pengambilan atau pemilihan gambar berhasil dilakukan. Implementasi ini menunjukkan pemanfaatan fitur native perangkat melalui Flutter sehingga aplikasi dapat berinteraksi langsung dengan hardware dan sistem operasi perangkat mobile.
