# Smart-Patrol Vision & Logbook

Aplikasi cerdas berbasis **Flutter** yang mengintegrasikan pencatatan cerdas tersinkronisasi (Logbook Cloud dengan MongoDB) dan inspeksi jalan raya berbantuan simulasi Visi Komputer serta Pengolahan Citra Digital (Laboratorium PCD murni dart tanpa library OpenCV).

## 🚀 Fitur Utama

### 1. Smart-Patrol Vision & Simulasi Deteksi
- **Live Camera Preview:** Inspeksi langsung melalui kamera belakang ponsel tanpa distorsi aspek rasio.
- **Dynamic Overlay & Text Shadow:** Menampilkan simulasi bounding-box cerdas dengan tipe kerusakan (contoh: Retakan `D00`, Lubang `D40`). Setiap tingkat kerusakan diklasifikasi menggunakan warna spesifik (Merah untuk berat, Kuning untuk ringan).
- **Toggle Hardware & UI:** Fitur mengaktifkan Senter (Torch) dan mematikan matriks penanda secara real-time.
- **Auto-Dispose Lifecycle:** Mematikan kamera secara otomatis begitu aplikasi dipicu masuk ke latar belakang.

### 2. Laboratorium PCD (Pengolahan Citra Digital)
Aplikasi membedah foto (murni memanfaatkan komputasi matematika _Isolate_ di belakang layar) menjadi berbagai model citra:
- **Pengaturan Kecerahan (Brightness):** Modifikasi nilai RGB secara dinamis menggunakan slider.
- **Grayscale:** Pemudaran piksel ke abu-abu murni sesuai bobot Luma.
- **Threshold / Biner:** Mengkonversi gambar menjadi wujud bayangan hitam putih ekstrem.
- **Low-pass Filter (Gaussian Blur):** Meratakan piksel dengan sekitarnya demi mengurangi noise kamera.
- **High-pass Filter (Edge Detection - Sobel):** Menemukan batas warna atau patahan jalan yang ekstrem.
- **Sharpen:** Penajaman tepian patahan agar visual jalan semakin menonjol.
- **Visualisasi Histogram:** Membedah frekuensi spektrum cahaya pada citra menjadi grafik batang yang mendetail.

### 3. Logbook tersinkronisasi ke MongoDB
- Memanfaatkan **Atlas MongoDB** untuk integrasi Catatan Patroli.
- **Network Safety / Guard Koneksi:** Terdapat notifikasi error user-friendly apabila koneksi terputus.
- **Access Policy:** Menerapkan kedaulatan log (Sovereignty) di mana penulis asli saja yang berhak menghapus/mengedit, namun dilengkapi fitur visibilitas publik/privat.

---

## 🛠️ Prasyarat (Prerequisites)

Sebelum menjalankan projek, pastikan komputer Anda sudah memenuhi syarat berikut:
- **Flutter SDK:** minimal versi `3.10.x` (Disarankan versi terbaru).
- **Dart:** versi `3.x` ke atas.
- **Perangkat / Emulator:** Kompatibel dengan Android (direkomendasikan menjalankan ke perangkat sungguhan karena adanya akses fitur Kamera).

---

## ⚙️ Instalasi

1. **Clone repositori**
   Simpan kode sumber aplikasi ini ke folder lokal Anda.
2. **Install Dependensi**
   Buka terminal di root project dan jalankan perintah:
   ```bash
   flutter pub get
   ```
3. **Konfigurasi Environment Variable (`.env`)**
   Buatlah sebuah file bernama `.env` di folder root project (bersebelahan dengan `pubspec.yaml`), dan isi dengan kredensial database beserta standar logging Anda:
   ```env
   # Ganti kredensial url di bawah dengan url MongoDB Atlas milik Anda
   MONGODB_URI=mongodb+srv://<USERNAME>:<PASSWORD>@cluster.mongodb.net/smart_patrol?retryWrites=true&w=majority
   
   # Konfigurasi Log (Level 1 Error, Level 2 Info, Level 3 Debug terminal)
   LOG_LEVEL=3
   ```
4. **Generate File Hive/Adaptor (Jika Menggunakan Hive Local)**
   Jika ada kegagalan *Missing Adaptor*, pastikan file generated telah dibuat melalui runner:
   ```bash
   dart run build_runner build -d
   ```
5. **Jalankan Aplikasi**
   Hubungkan device fisik Anda, kemudian jalankan:
   ```bash
   flutter run
   ```

---

## 📚 Tutorial & Panduan Penggunaan

### 1. Memulai Patroli
- Saat menjalankan perdana aplikasi, tekan tombol pada layar **Onboarding** untuk melompat masuk ke menu logbook/kamera.
- Jika ditanya "Permission to access Camera", tekan **Izinkan / Allow**. Anda wajib mengizinkan untuk menggunakan perangkat keras kamera.

### 2. Memindai Kerusakan (Vision)
- Masuk ke tab **Inspeksi (Kamera)**.
- Layar pemindaian pintar akan aktif dengan indikator crosshair di tengah bertuliskan *"Searching for Road Damage..."*.
- Otomatis setiap 3 detik, simulasi deteksi (kotak-kotak berwarna penanda lubang dan retakan) akan muncul secara merata dan menyesuaikan ukurannya dengan perangkat HP Anda.
- **Tombol Kiri Bawah:** Mengaktifkan atau mematikan lampu kilat / Senter (bila kondisi malam hari).
- **Tombol Tengah (Bulat):** Mengambil gambar kerusakan (Jepret).
- **Ikon Mata (Kanan Atas):** Menyembunyikan lapisan indikator pemindaian untuk melihat hasil kamera murni.

### 3. Mengolah Gambar (Laboratorium PCD)
- Tekan **Tombol Kanan Bawah** di halaman kamera untuk membuka Galeri Foto yang sudah Anda jepret.
- Klik pada salah satu lembar foto untuk mulai memanipulasi citranya di **Laboratorium PCD**.
- **Panel Filter bawah:** Coba dan ketuk berbagai teknik (*Grayscale, Biner, Blur, Edge Detect, Sharpen*). Sistem tidak akan memblokir (*freeze*) layar Anda saat mengeksekusi metode yang berat, karena bekerja pada _Background Isolate_.
- Jika sudah selesai mengutak-atik manipulasi gambar, tap tombol ✅ (Ceklis) di Kanan atas.

### 4. Menyimpan Hasil & Mengelola Tim
- Masuk ke tab **Logbook**.
- Anda dapat membuat Log Baru di mana MongoDB akan mengeksekusi *Insert*.
- Jika ingin membagikan catatan ke atasan / member lain, aktifkan toggle visibilitas menjadi "Publik". Tanda mata akan memberikan hak baca namun tidak hak menghapus (dipertahankan oleh *Sovereignty*).
