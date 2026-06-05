# PENJELASAN SINGKAT WIDGET APLIKASI
### Tugas Praktikum Modul 8 & 9: Notifikasi & API Perangkat Keras
**Nama: Qonita Rahayu Atmi**  
**NIM: 2311102128**  

---

Aplikasi ini dibuat menggunakan framework Flutter dengan menerapkan fitur pengambilan gambar langsung dari Kamera (menggunakan **Camera API** via paket `camera`), pemilihan gambar dari Galeri (menggunakan paket `image_picker`), serta pemicuan notifikasi lokal (menggunakan paket `flutter_local_notifications`). UI didesain secara premium dengan tema gelap modern (**Obsidian Dark Mode**).

Berikut adalah penjelasan singkat mengenai setiap widget dan layanan (service) utama yang digunakan dalam source code aplikasi ini:

---

## 1. Layanan Pendukung (Services)

### `NotificationService`
* **Deskripsi:** Merupakan kelas *Singleton* (hanya memiliki satu instance global) yang berfungsi untuk membungkus seluruh konfigurasi dan metode terkait notifikasi lokal.
* **Fungsi Utama:**
  * **`init()`**: Menginisialisasi `FlutterLocalNotificationsPlugin` dengan ikon bawaan Android `@mipmap/ic_launcher` serta mengatur callback penanganan klik notifikasi.
  * **`showNotification(...)`**: Meminta izin notifikasi dinamis secara runtime untuk Android 13+ menggunakan `permission_handler` jika belum diberikan. Kemudian, memicu notifikasi instan dengan konfigurasi prioritas tinggi (`Importance.max` dan `Priority.high`) agar muncul sebagai head-up banner di status bar perangkat pengguna.

---

## 2. Kelas Widget Utama

### `MyApp` (StatelessWidget)
* **Deskripsi:** Merupakan root widget dari aplikasi Flutter yang pertama kali dipanggil saat dijalankan.
* **Fungsi Utama:**
  * Mengatur judul aplikasi global dan menonaktifkan banner debug (`debugShowCheckedModeBanner: false`).
  * Menerapkan tema gelap tingkat lanjut (**Premium Obsidian Dark Theme**) menggunakan `ThemeData.dark()` yang dipadukan dengan aksen warna kustom seperti warna nila neon (`Color(0xFF6366F1)`) untuk primary, dan sian elektrik (`Color(0xFF00FFD1)`) untuk secondary/accent.
  * Menetapkan `PremiumHomeScreen` sebagai halaman utama (`home`).

---

### `PremiumHomeScreen` (StatefulWidget)
* **Deskripsi:** Widget halaman utama aplikasi yang memfasilitasi pengguna untuk berinteraksi dengan kamera dan galeri serta menampilkan hasilnya langsung di layar yang sama.
* **Fungsi Utama:**
  * **`initState()`**: Secara otomatis memicu permintaan izin notifikasi saat aplikasi pertama kali terbuka.
  * **`_takePhotoWithCameraAPI()`**: Metode yang mengecek ketersediaan modul hardware kamera laptop/emulator. Meminta izin akses kamera, lalu membuka layar kustom `CameraScreen`. Setelah foto diambil, mengupdate state gambar (`_selectedImage`) dan memicu notifikasi lokal bahwa pengambilan gambar berhasil.
  * **`_pickPhotoFromGallery()`**: Metode yang membuka galeri perangkat menggunakan instansiasi `ImagePicker`. Setelah foto dipilih, mengupdate state gambar (`_selectedImage`) dan memicu notifikasi lokal keberhasilan pemilihan foto dari galeri.
  * **`_clearImage()`**: Menghapus foto yang sedang ditampilkan dan mengembalikannya ke tampilan awal (placeholder).
  * **`build(...)`**: Menyusun tata letak (layout) halaman utama yang responsif, terdiri dari:
    * **`AppBar`**: Menampilkan nama aplikasi dengan ikon yang stylish dan tombol hapus cepat jika ada gambar aktif.
    * **`Expanded Container Frame`**: Wadah dinamis berbingkai kaca tipis (glassmorphism style). Jika foto belum dipilih, wadah menampilkan dekorasi ikon pencarian melingkar serta deskripsi instruktif. Jika foto sudah ada, wadah memuat visual foto dengan sudut membulat rapi, dibalut pendar cahaya sian neon di sekelilingnya, serta label penunjuk di bagian bawah.
    * **`Row Buttons`**: Menampung dua buah tombol kustom besar yang berdampingan: tombol kamera dengan gradasi warna nila (Indigo) dan tombol galeri dengan outline warna sian elektrik (Teal).

---

### `CameraScreen` (StatefulWidget)
* **Deskripsi:** Widget layar kustom berformat penuh (fullscreen) yang secara langsung berinteraksi dengan **Camera API** tingkat rendah untuk menampilkan pratinjau kamera live dan menangkap gambar secara instan.
* **Fungsi Utama:**
  * **`initState()`**: Menginisialisasi `CameraController` menggunakan deskripsi kamera pertama yang terdeteksi dengan preset resolusi tinggi (`ResolutionPreset.high`) dan menonaktifkan audio (karena hanya untuk foto).
  * **`dispose()`**: Membersihkan controller kamera dari memori saat layar ditutup untuk mencegah kebocoran memori (memory leaks).
  * **`_capturePhoto()`**: Memastikan proses inisialisasi selesai, memanggil fungsi bawaan `takePicture()` dari Camera API untuk mengambil foto, lalu menutup layar kustom sambil mengirimkan file path foto ke halaman utama.
  * **`build(...)`**: Menyusun antarmuka kamera profesional yang menyajikan:
    * **`FutureBuilder`**: Menunggu inisialisasi kamera selesai. Menampilkan loading spinner sian cantik selama memuat kamera laptop.
    * **`CameraPreview`**: Komponen pratinjau yang menampilkan stream live dari lensa kamera perangkat secara real-time.
    * **`Grid Lines (Rule of Thirds)`**: Garis kisi fotografi bantu berpola 3x3 berwarna putih semi-transparan untuk menambah nilai estetika antarmuka pengambilan gambar.
    * **`Back Button Overlay`**: Tombol melingkar di atas pratinjau untuk kembali ke halaman utama.
    * **`Bottom Capture Controls`**: Bilah hitam transparan di bagian bawah yang berisi tombol rana (*shutter button*) melingkar ganda putih-bersinar yang memicu pengambilan gambar saat diketuk.
