# ParQr - Aplikasi Manajemen Parkir Modern

ParQr adalah aplikasi manajemen parkir modern berbasis Flutter yang mendukung fitur bagi pengunjung, operator, dan admin.

## Fitur Utama
- **Pengunjung**: Registrasi, pencarian parkir, booking, check-in/out via QR Code, pembayaran (Cash/QRIS).
- **Operator**: Verifikasi pembayaran, scan QR pengunjung, kelola lokasi parkir.
- **Admin**: Verifikasi pendaftaran operator dan manajemen data.

## Persiapan (Setup)
1. Salin `.env.example` menjadi `.env`.
2. Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di dalam `.env` sesuai dengan konfigurasi proyek Supabase Anda.

## Cara Menjalankan (Run Command)
Gunakan argumen `--dart-define-from-file` saat menjalankan aplikasi agar dapat memuat konfigurasi dari file `.env`:
```bash
flutter run --dart-define-from-file=.env
```

## Build APK
Untuk melakukan build APK internal/debug, jalankan:
```bash
flutter build apk --debug --dart-define-from-file=.env
```

---
*Proyek ini masih dalam tahap MVP (Sprint 6).*
