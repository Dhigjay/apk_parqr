<div align="center">

# 🚗 **PARQR** 🚙
### *Aplikasi Manajemen Parkir Modern Berbasis Cerdas*

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![BLoC](https://img.shields.io/badge/BLoC-State_Management-blue?style=for-the-badge)](https://bloclibrary.dev/)

---

*“Ucapkan selamat tinggal pada karcis parkir hilang, sambut masa depan parkir digital.”*

</div>

<details open>
  <summary><b>📚 Daftar Isi</b></summary>
  <ol>
    <li><a href="#-pengertian-apa-itu-parqr">Pengertian</a></li>
    <li><a href="#-tujuan-utama">Tujuan</a></li>
    <li><a href="#-fungsi--fitur-unggulan">Fungsi & Fitur</a></li>
    <li><a href="#-panduan-penggunaan-interaktif">Panduan Penggunaan</a></li>
    <li><a href="#-teknologi-yang-digunakan">Teknologi</a></li>
  </ol>
</details>

---

## 📖 Pengertian: Apa itu Parqr?

**Parqr** adalah aplikasi manajemen parkir pintar (Smart Parking) yang dibangun untuk mendigitalkan dan menyederhanakan proses keluar-masuk kendaraan di area parkir. Menggunakan teknologi **QR Code** untuk identifikasi otomatis, Parqr mengeleminasi kebutuhan tiket kertas tradisional, mempercepat proses pembayaran, dan menyajikan data parkir yang aman, terintegrasi, dan *real-time*.

---

## 🎯 Tujuan Utama

Mengapa aplikasi ini diciptakan?

- **Go Green 🌿:** Mengurangi drastis penggunaan kertas untuk karcis parkir.
- **Efisiensi Waktu ⏱️:** Mempercepat antrean di gerbang masuk dan keluar dengan scan otomatis.
- **Keamanan Data 🔒:** Menghindari kehilangan tiket karena semuanya tersimpan dengan aman di perangkat seluler pengguna atau tercatat di *cloud*.
- **Transparansi Biaya 💰:** Memberikan informasi yang jelas mengenai tarif dan durasi parkir secara presisi.

---

## ✨ Fungsi & Fitur Unggulan

Berikut adalah apa saja yang bisa dilakukan oleh aplikasi Parqr:

| Fitur | Deskripsi | Status |
| :--- | :--- | :---: |
| 📲 **Scan QR Masuk/Keluar** | Pembuatan dan pemindaian kode QR unik untuk setiap kendaraan (Mobile Scanner & QR Flutter). | ✅ |
| 📍 **Pelacakan Lokasi** | Geolokasi otomatis untuk mencatat detail area parkir (Geolocator). | ✅ |
| 💳 **Pembayaran Digital** | Terintegrasi dengan sistem kalkulasi biaya berdasarkan durasi (State Payment Bloc). | ✅ |
| 👤 **Manajemen Profil** | Kelola data kendaraan, riwayat parkir, dan saldo. | ✅ |
| ⚡ **Real-time Database** | Sinkronisasi data seketika dengan menggunakan **Supabase**. | ✅ |

---

## 🛠️ Panduan Penggunaan (Interaktif)

*Klik pada setiap langkah di bawah ini untuk melihat detail panduan!*

<details>
<summary><b>Langkah 1: Instalasi & Setup Lingkungan</b></summary>
<br>

1. Pastikan Anda telah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install) versi `>=3.0.0`.
2. Clone repository ini:
   ```bash
   git clone https://github.com/yourusername/apk_parqr.git
   ```
3. Masuk ke direktori aplikasi:
   ```bash
   cd apk_parqr
   ```
4. Unduh dependensi:
   ```bash
   flutter pub get
   ```
</details>

<details>
<summary><b>Langkah 2: Menjalankan Aplikasi</b></summary>
<br>

1. Hubungkan perangkat fisik via USB atau buka Emulator/Simulator.
2. Jalankan perintah berikut:
   ```bash
   flutter run
   ```
3. (Opsional) Untuk mem-build APK rilis:
   ```bash
   flutter build apk --release
   ```
</details>

<details>
<summary><b>Langkah 3: Alur Pengguna (User Flow) di Aplikasi</b></summary>
<br>

1. **Registrasi/Login:** Buat akun untuk menyimpan plat nomor kendaraan.
2. **Masuk Gerbang (Check-In):** Buka aplikasi, tampilkan QR Code ke *scanner* pos jaga, atau gunakan kamera ponsel untuk *scan* kode pos.
3. **Pengecekan Status:** Pantau durasi berjalan dan estimasi harga dari halaman **Home**.
4. **Keluar Gerbang (Check-Out):** Selesaikan pembayaran melalui *QR Pay* atau saldo digital saat meninggalkan area parkir.
</details>

---

## 💻 Teknologi yang Digunakan

| Kategori | Package/Teknologi |
| :--- | :--- |
| **Framework** | Flutter `>=3.0.0` |
| **State Management** | `flutter_bloc` / `cubit` |
| **Backend & Auth** | `supabase_flutter` |
| **Routing** | `go_router` |
| **Dependency Injection** | `get_it` |
| **Barcode/QR** | `qr_flutter`, `mobile_scanner` |

---

<div align="center">
  <sub>Dibuat dengan ❤️ oleh tim Parqr.</sub>
</div>
