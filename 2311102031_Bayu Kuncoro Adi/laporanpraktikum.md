<div align="center">

<br>

# LAPORAN PRAKTIKUM  
# APLIKASI BERBASIS PLATFORM

<br>

## MODUL 08-09
## Mobile - Camera & Notification app

<br>

<img src="assets/logo.jpeg" width="300">

<br><br>

### Disusun Oleh

**Bayu Kuncoro Adi**  
**2311102031**  
**S1 IF-11-REG01**

<br>

### Dosen Pengampu

**Dimas Fanny Hebrasianto Permadi, S.ST., M.Kom**

<br>

### Asisten Praktikum

**Apri Pandu Wicaksono**  
**Rangga Pradarrell Fathi**

<br><br>

### LABORATORIUM HIGH PERFORMANCE  
### FAKULTAS INFORMATIKA  
### UNIVERSITAS TELKOM PURWOKERTO  
### 2026

</div>

---

# Laporan Praktikum Modul 8-9
## Notifikasi & API Perangkat Keras

---

## Dasar Teori

Flutter adalah framework lintas platform yang memungkinkan pengembang membuat aplikasi untuk Android, iOS, web, dan desktop menggunakan satu codebase yang sama. Pada praktikum Modul 8–9 ini, dikembangkan sebuah **Camera & Notification App**, yaitu aplikasi yang mengintegrasikan dua fungsi utama, yaitu mengambil atau memilih foto melalui kamera maupun galeri, serta menampilkan notifikasi lokal sebagai konfirmasi setelah foto berhasil dipilih.


### Camera & Image Picker

Flutter tidak menyediakan akses kamera secara langsung secara bawaan, sehingga diperlukan package tambahan bernama `image_picker`. Package ini memungkinkan aplikasi untuk mengambil gambar melalui kamera perangkat maupun memilih gambar yang sudah tersimpan di galeri. Proses pengambilan gambar dilakukan menggunakan objek `ImagePicker` dengan memanggil method `pickImage()` yang membutuhkan parameter `source`. Parameter `ImageSource.camera` digunakan untuk mengakses kamera, sedangkan `ImageSource.gallery` digunakan untuk membuka galeri foto. Method tersebut mengembalikan objek bertipe `XFile?`, yang kemudian dikonversi menjadi objek `File` dari package `dart:io` sehingga gambar dapat ditampilkan pada antarmuka menggunakan widget `Image.file`.


### Local Notification

Notifikasi lokal pada Flutter dapat diimplementasikan menggunakan package `flutter_local_notifications`, yang memungkinkan aplikasi menampilkan notifikasi sistem pada perangkat Android maupun iOS tanpa memerlukan koneksi internet atau layanan server. Sebelum fitur notifikasi dapat digunakan, plugin harus diinisialisasi terlebih dahulu melalui objek `FlutterLocalNotificationsPlugin` dengan konfigurasi awal menggunakan `AndroidInitializationSettings`. Proses inisialisasi ini dilakukan di dalam fungsi `main()` sebelum pemanggilan `runApp()` agar seluruh layanan notifikasi telah siap saat aplikasi mulai berjalan.

Pada perangkat dengan Android 13 atau versi yang lebih baru, aplikasi diwajibkan meminta izin notifikasi secara eksplisit kepada pengguna. Permintaan izin tersebut dilakukan melalui method `requestNotificationsPermission()` yang diakses menggunakan `resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()`. Setelah izin diberikan, notifikasi dapat ditampilkan menggunakan method `show()`, yang memerlukan beberapa parameter, yaitu ID notifikasi, judul, isi pesan, serta konfigurasi detail notifikasi yang didefinisikan dalam objek `NotificationDetails`. Dengan mekanisme ini, aplikasi dapat memberikan informasi atau umpan balik kepada pengguna secara langsung melalui notifikasi sistem.


### StatefulWidget dan setState

Karena antarmuka aplikasi harus diperbarui secara dinamis saat pengguna memilih atau mengambil foto, halaman utama diimplementasikan menggunakan `StatefulWidget`. Ketika proses pemilihan foto berhasil dilakukan, nilai variabel `_imageFile` diperbarui melalui pemanggilan `setState()`, sehingga widget `Image.file` secara otomatis melakukan render ulang dan menampilkan gambar terbaru yang dipilih pengguna. Selain itu, aplikasi memanfaatkan variabel `_isLoading` untuk mengelola status proses pengambilan gambar, sehingga indikator loading dapat ditampilkan selama proses berlangsung dan disembunyikan setelah proses selesai.


---



## Code Program

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 8-9',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  File? imageFile;

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'photo_channel',
      'Photo Notification',
      channelDescription: 'Notifikasi Foto',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Foto Berhasil',
      message,
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> openCamera() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => imageFile = File(photo.path));
      await showNotification('Foto berhasil diambil dari kamera');
    }
  }

  Future<void> openGallery() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => imageFile = File(photo.path));
      await showNotification('Foto berhasil dipilih dari galeri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi & API Perangkat Keras',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Modul 8-9 — Platform Mobile',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Color(0xFF1976D2), width: 3),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF1976D2),
                    child: Text(
                      'BK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayu Kuncoro Adi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'NIM 2311102031',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB5D4F4),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: imageFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Color(0xFFB5D4F4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada foto',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ambil atau pilih foto untuk ditampilkan',
                      style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openCamera,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Ambil Foto (Kamera)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openGallery,
                icon: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1976D2),
                ),
                label: const Text(
                  'Pilih Foto dari Galeri',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF1976D2),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
```

---

## Penjelasan Singkat Tiap Widget

## MaterialApp

MaterialApp merupakan widget utama yang menjadi fondasi aplikasi Flutter berbasis Material Design. Pada program ini, widget tersebut digunakan untuk mengatur konfigurasi global aplikasi, seperti judul aplikasi melalui properti title, tema tampilan menggunakan theme, serta menentukan halaman pertama yang akan ditampilkan melalui properti home. Selain itu, properti debugShowCheckedModeBanner: false digunakan untuk menghilangkan label debug yang biasanya muncul di pojok kanan atas saat aplikasi dijalankan dalam mode pengembangan.

## Scaffold

Scaffold berfungsi sebagai kerangka dasar tampilan aplikasi. Widget ini menyediakan struktur halaman yang lengkap, seperti AppBar, Body, Drawer, BottomNavigationBar, dan komponen lainnya. Pada aplikasi ini, Scaffold digunakan untuk menampung AppBar sebagai bagian header dan body sebagai area utama yang berisi tampilan foto serta tombol untuk mengakses kamera dan galeri.

## AppBar

AppBar merupakan widget yang digunakan untuk membuat bilah navigasi di bagian atas aplikasi. Pada kode ini, AppBar digunakan untuk menampilkan judul halaman berupa teks "Notifikasi & API Perangkat Keras". Keberadaan AppBar membantu pengguna memahami fungsi utama aplikasi yang sedang dijalankan.

## Padding

Padding digunakan untuk memberikan jarak antara isi halaman dengan tepi layar. Pada program ini, seluruh konten di dalam body dibungkus oleh widget Padding dengan nilai EdgeInsets.all(20), sehingga elemen-elemen yang ditampilkan tidak menempel langsung pada batas layar dan tampak lebih rapi serta nyaman dilihat.

## Column

Column merupakan widget yang digunakan untuk menyusun beberapa widget secara vertikal dari atas ke bawah. Pada aplikasi ini, Column digunakan untuk mengatur posisi area tampilan gambar, tombol kamera, tombol galeri, dan ruang kosong tambahan agar tersusun secara berurutan dalam satu halaman.

## Expanded

Expanded digunakan agar suatu widget dapat memanfaatkan ruang kosong yang tersedia secara maksimal di dalam Column atau Row. Pada program ini, widget Expanded membungkus area tampilan gambar sehingga bagian tersebut dapat menyesuaikan ukuran ruang yang tersedia dan mendorong tombol-tombol tetap berada di bagian bawah halaman.

## Center

Center berfungsi untuk menempatkan widget anak tepat di tengah area yang tersedia. Pada aplikasi ini, widget Center digunakan agar teks "Belum ada foto" maupun gambar yang dipilih dari kamera atau galeri selalu berada pada posisi tengah layar sehingga tampilan menjadi lebih seimbang.

## Text

Text digunakan untuk menampilkan informasi dalam bentuk tulisan kepada pengguna. Dalam aplikasi ini, widget Text digunakan pada beberapa bagian, seperti menampilkan pesan "Belum ada foto" ketika belum ada gambar yang dipilih serta menampilkan tulisan pada tombol kamera dan galeri. Properti TextStyle digunakan untuk mengatur ukuran huruf agar teks lebih mudah dibaca.

## Image.file

Image.file digunakan untuk menampilkan gambar yang berasal dari file lokal pada perangkat. Setelah pengguna mengambil foto melalui kamera atau memilih gambar dari galeri, path file tersebut disimpan dalam variabel imageFile, kemudian ditampilkan menggunakan widget Image.file. Dengan demikian, pengguna dapat langsung melihat hasil foto yang dipilih pada layar aplikasi.

## SizedBox

SizedBox digunakan untuk memberikan ukuran tertentu atau menciptakan jarak antar widget. Pada aplikasi ini, SizedBox(width: double.infinity) digunakan agar tombol memiliki lebar penuh mengikuti ukuran layar. Selain itu, SizedBox(height: 10) dan SizedBox(height: 20) digunakan untuk memberikan jarak vertikal antar komponen sehingga tampilan tidak terlalu rapat.

## ElevatedButton

ElevatedButton merupakan widget tombol dengan efek elevasi atau bayangan yang memberikan kesan menonjol. Pada program ini terdapat dua ElevatedButton, yaitu tombol untuk membuka kamera melalui fungsi openCamera() dan tombol untuk membuka galeri melalui fungsi openGallery(). Ketika tombol ditekan, aplikasi akan menjalankan fungsi terkait untuk mengambil atau memilih foto, kemudian menampilkan hasilnya beserta notifikasi lokal.

---

## HASIL SCREENSHOOTS

<img src="assets/WhatsApp Image 2026-06-01 at 23.12.23.jpeg">

<img src="assets/WhatsApp Image 2026-06-01 at 23.13.27.jpeg">

<img src="assets/WhatsApp Image 2026-06-01 at 23.18.07.jpeg">

<img src="assets">

<img src="assets">

<img src="assets">

<img src="assets">

## Kesimpulan

Pada praktikum Modul 8–9 ini, berhasil dikembangkan sebuah aplikasi Flutter yang mengintegrasikan fitur akses perangkat keras dan notifikasi lokal. Melalui package image_picker, aplikasi dapat memanfaatkan kamera perangkat untuk mengambil foto maupun mengakses galeri untuk memilih gambar yang sudah tersimpan. Foto yang dipilih kemudian ditampilkan secara langsung pada antarmuka menggunakan widget Image.file, sementara perubahan tampilan dikelola melalui mekanisme state pada StatefulWidget.

Selain itu, aplikasi juga mengimplementasikan notifikasi lokal menggunakan package flutter_local_notifications. Fitur ini memungkinkan aplikasi memberikan umpan balik kepada pengguna dalam bentuk notifikasi sistem setelah proses pengambilan atau pemilihan foto berhasil dilakukan. Implementasi tersebut menunjukkan bagaimana Flutter dapat berinteraksi dengan fitur-fitur native perangkat melalui package tambahan. Dengan demikian, praktikum ini memberikan pemahaman mengenai penggunaan API perangkat keras, pengelolaan state aplikasi, serta implementasi notifikasi lokal dalam pengembangan aplikasi mobile berbasis Flutter.