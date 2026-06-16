# 🅿 ParQr — Product Requirements Document (PRD)

> Aplikasi Manajemen Parkir Modern dengan QR Code  
> Platform: Flutter (Android & iOS) | Backend: Supabase | Versi: v1.0.0 MVP

---

## Daftar Isi

1. [Ringkasan Produk](#1-ringkasan-produk)
2. [Tujuan Produk](#2-tujuan-produk)
3. [Pengguna & Role](#3-pengguna--role)
4. [User Flow Detail](#4-user-flow-detail)
5. [Fitur Lengkap per Modul](#5-fitur-lengkap-per-modul)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Struktur Folder Flutter](#7-struktur-folder-flutter)
8. [Dependensi (pubspec.yaml)](#8-dependensi-pubspecyaml)
9. [Langkah Pembuatan Aplikasi](#9-langkah-pembuatan-aplikasi)
10. [ERD — Penjelasan Tabel & Relasi](#10-erd--penjelasan-tabel--relasi)
11. [Stitch Design Prompt](#11-stitch-design-prompt)

---

## 1. Ringkasan Produk

| Atribut | Detail |
|---|---|
| **Nama Produk** | ParQr |
| **Platform** | Mobile (Android & iOS) — Flutter |
| **Database** | PostgreSQL via Supabase |
| **Backend** | Supabase (Auth, DB, Storage, Realtime) + Payment Gateway |
| **Target Pengguna** | Pengunjung, Operator Parkir, Admin ParQr |
| **Versi** | v1.0.0 MVP |

---

## 2. Tujuan Produk

- Memudahkan pengunjung memesan dan membayar parkir secara digital
- Membantu operator/pemilik lahan mengelola parkir secara real-time
- Memberikan admin kontrol penuh atas ekosistem aplikasi

---

## 3. Pengguna & Role

### Role 1 — Pengunjung / Pengguna

- Registrasi & login dengan email/password
- Melengkapi profil diri dan data kendaraan (nama, alamat, no polisi, merk, foto kendaraan)
- Mencari tempat parkir yang terdaftar di aplikasi
- Memesan slot parkir (sistem seperti tiket)
- Generate QR Code untuk scan masuk oleh operator
- Menyimpan lokasi kendaraan via aplikasi
- Melihat stopwatch tarif parkir berjalan
- Memilih metode pembayaran: Cash atau QRIS/Payment Gateway
- Menerima QR Code keluar setelah pembayaran berhasil
- Melihat riwayat parkir

### Role 2 — Operator / Pemilik Lahan

- Awalnya berperan sebagai user biasa
- Mendaftarkan lahan parkir via banner di Home
- Menginput: nama usaha, alamat, luas, jumlah lantai, kapasitas per lantai, tarif/jam, foto
- Pengajuan dikirim ke Admin untuk di-approve/reject
- Setelah approved: login dengan email+password khusus operator dari Admin
- Akses dashboard operator: statistik, daftar kendaraan aktif, riwayat
- Scan QR Code masuk: data kendaraan otomatis terekam
- Verifikasi pembayaran cash (konfirmasi manual)
- Scan QR Code keluar: kendaraan tercatat keluar
- CRUD data lahan parkir (slot, tarif, lantai)

### Role 3 — Admin / Pemilik Aplikasi

- Login via panel khusus admin
- Melihat semua pengajuan operator (pending/approved/rejected)
- Approve atau Reject pendaftaran operator + isi alasan reject
- Membuat akun operator (email+password) setelah approve
- Melihat seluruh data lahan, sesi parkir, dan statistik global

---

## 4. User Flow Detail

### Flow Pengunjung — Parkir Masuk

1. User download & buka app → halaman Login/Register
2. Register dengan email, password, nama, no HP
3. Login → redirect ke halaman Lengkapi Profil
4. Input data diri (nama lengkap, alamat) + data kendaraan (merk, model, no polisi, foto kendaraan)
5. Simpan → data tersimpan di database
6. Home screen: cari nama tempat parkir atau lokasi
7. Pilih tempat parkir → lihat detail (kapasitas, tarif, lantai)
8. Klik "Pesan Parkir" → konfirmasi pemesanan
9. Sistem generate QR Code unik → tampil di layar user
10. User tunjukkan QR ke operator → operator scan → data masuk
11. User klik "Simpan Lokasi" → koordinat GPS kendaraan terkirim ke operator
12. Stopwatch tarif mulai berjalan di layar user

### Flow Pengunjung — Keluar Parkir

1. User klik "Keluar Parkir" → stopwatch **TETAP berjalan** (anti-kecurangan)
2. Tampil halaman pembayaran dengan total tarif
3. Pilih metode: Cash atau QRIS
4. Jika **Cash** → user konfirmasi ke operator → operator verifikasi di appnya → QR keluar muncul
5. Jika **QRIS** → countdown 10 menit → setelah payment berhasil → QR keluar otomatis muncul
6. User tunjukkan QR keluar ke operator → scan → sesi parkir ditutup

### Flow Operator — Menerima & Melepas Kendaraan

1. Buka app → login sebagai operator
2. Dashboard: lihat kendaraan aktif, total pendapatan hari ini
3. Klik tombol scan → arahkan kamera ke QR masuk pengunjung
4. Sistem tampilkan data: nama, no polisi, foto kendaraan
5. Sesi parkir tercatat dalam sistem
6. Saat keluar: user pilih cash → operator terima notifikasi verifikasi → klik Verifikasi
7. Setelah verifikasi → QR keluar muncul di app user
8. Operator scan QR keluar → sesi ditutup, kendaraan keluar tercatat

---

## 5. Fitur Lengkap per Modul

### Modul Autentikasi

- Register (email, password, nama, HP)
- Login (email + password)
- Forgot password via email
- Role-based routing: user / operator / admin
- JWT token + refresh token (via Supabase Auth)

### Modul Profil & Kendaraan

- Form lengkap profil: nama, alamat rumah
- Input kendaraan: merk, model, jenis (motor/mobil), no polisi
- Upload foto kendaraan (Supabase Storage)
- Multi-kendaraan: satu akun bisa punya beberapa kendaraan
- Edit & hapus kendaraan

### Modul Pencarian Parkir

- Search by nama atau lokasi
- List tempat parkir dengan info: nama, jarak, tarif/jam, kapasitas sisa
- Detail halaman: peta (dark mode), info lantai, slot tersedia
- Filter by: harga, jarak, ketersediaan

### Modul Booking & QR

- Pemesanan slot parkir dengan pilih kendaraan
- Generate QR Code unik tiap sesi (berisi session_id)
- QR Code untuk masuk (entry QR)
- QR Code untuk keluar setelah pembayaran (exit QR)
- Validasi QR: expired setelah 24 jam tidak dipakai

### Modul Tarif & Stopwatch

- Stopwatch mulai saat QR masuk berhasil di-scan operator
- Stopwatch tampil di layar user secara real-time
- Tarif dihitung: durasi × tarif_per_jam (dibulatkan per 30 menit atau per jam, tergantung setting operator)
- Stopwatch **TIDAK berhenti** saat user klik "Keluar Parkir" — hanya berhenti setelah pembayaran verified

### Modul Pembayaran

- Pilihan metode: Cash / QRIS
- Cash: notifikasi ke operator → operator klik Verifikasi → QR keluar dibuat
- QRIS: generate QRIS dari payment gateway, countdown 10 menit
- Webhook dari payment gateway: update status otomatis saat dibayar
- Jika timeout QRIS: user bisa generate ulang
- Bukti pembayaran tersimpan di history

### Modul Operator — Dashboard

- Statistik: kendaraan masuk hari ini, sedang parkir, pendapatan hari ini
- List kendaraan aktif: nama, no polisi, waktu masuk, lokasi slot, tarif berjalan
- History semua kendaraan (hari ini, minggu ini, bulan ini)
- Scan QR (masuk & keluar) via kamera
- Verifikasi pembayaran cash
- CRUD lahan: nama, tarif, lantai, slot, foto

### Modul Admin

- List pengajuan operator (pending, approved, rejected)
- Detail pengajuan: semua data bisnis + peta alamat
- Approve: sistem otomatis buat akun operator + kirim email
- Reject: wajib isi alasan (terkirim ke email pendaftar)
- Lihat semua data lahan terdaftar
- Statistik global aplikasi

---

## 6. Non-Functional Requirements

| Kategori | Requirement |
|---|---|
| **Performa** | Halaman pertama < 2 detik, real-time update < 1 detik |
| **Keamanan** | HTTPS, JWT, validasi QR server-side, enkripsi data sensitif |
| **Offline** | Tampilkan pesan informatif jika tidak ada koneksi internet |
| **Responsif** | UI optimal di layar 5" hingga 6.7" |
| **Aksesibilitas** | Kontras warna minimal 4.5:1 |

---

## 7. Struktur Folder Flutter

Menggunakan arsitektur **Clean Architecture** + **BLoC/Cubit** untuk state management.

```
lib/
├── main.dart                         # Entry point
├── app.dart                          # MaterialApp + GoRouter setup
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       ├── qr_utils.dart
│       └── location_utils.dart
│
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── auth_remote_ds.dart
│   │   │   ├── user_remote_ds.dart
│   │   │   ├── vehicle_remote_ds.dart
│   │   │   ├── parking_lot_remote_ds.dart
│   │   │   ├── parking_session_remote_ds.dart
│   │   │   └── payment_remote_ds.dart
│   │   └── local/
│   │       └── auth_local_ds.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── vehicle_model.dart
│   │   ├── parking_lot_model.dart
│   │   ├── parking_slot_model.dart
│   │   ├── parking_session_model.dart
│   │   ├── payment_model.dart
│   │   └── operator_registration_model.dart
│   └── repositories/
│       ├── auth_repo_impl.dart
│       ├── user_repo_impl.dart
│       ├── vehicle_repo_impl.dart
│       ├── parking_lot_repo_impl.dart
│       ├── parking_session_repo_impl.dart
│       └── payment_repo_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── vehicle_entity.dart
│   │   ├── parking_lot_entity.dart
│   │   ├── parking_slot_entity.dart
│   │   ├── parking_session_entity.dart
│   │   └── payment_entity.dart
│   ├── repositories/
│   │   ├── i_auth_repository.dart
│   │   ├── i_user_repository.dart
│   │   ├── i_vehicle_repository.dart
│   │   ├── i_parking_lot_repository.dart
│   │   ├── i_parking_session_repository.dart
│   │   └── i_payment_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   └── logout_usecase.dart
│       ├── user/
│       │   ├── complete_profile_usecase.dart
│       │   └── get_profile_usecase.dart
│       ├── vehicle/
│       │   ├── add_vehicle_usecase.dart
│       │   ├── update_vehicle_usecase.dart
│       │   └── delete_vehicle_usecase.dart
│       ├── parking/
│       │   ├── search_parking_lots_usecase.dart
│       │   ├── book_parking_usecase.dart
│       │   ├── check_in_usecase.dart
│       │   ├── save_vehicle_location_usecase.dart
│       │   ├── initiate_checkout_usecase.dart
│       │   └── confirm_exit_usecase.dart
│       └── payment/
│           ├── create_payment_usecase.dart
│           ├── verify_cash_payment_usecase.dart
│           └── get_payment_status_usecase.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── profile/
│   │   │   ├── profile_cubit.dart
│   │   │   └── profile_state.dart
│   │   ├── vehicle/
│   │   │   ├── vehicle_cubit.dart
│   │   │   └── vehicle_state.dart
│   │   ├── parking_session/
│   │   │   ├── parking_session_bloc.dart
│   │   │   ├── parking_session_event.dart
│   │   │   └── parking_session_state.dart
│   │   ├── payment/
│   │   │   ├── payment_cubit.dart
│   │   │   └── payment_state.dart
│   │   └── operator/
│   │       ├── operator_dashboard_cubit.dart
│   │       └── operator_dashboard_state.dart
│   │
│   ├── pages/
│   │   ├── splash/
│   │   │   └── splash_page.dart
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── forgot_password_page.dart
│   │   ├── onboarding/
│   │   │   ├── complete_profile_page.dart
│   │   │   └── add_vehicle_page.dart
│   │   ├── user/
│   │   │   ├── home/
│   │   │   │   ├── home_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── parking_card_widget.dart
│   │   │   │       └── search_bar_widget.dart
│   │   │   ├── parking_detail/
│   │   │   │   └── parking_detail_page.dart
│   │   │   ├── booking/
│   │   │   │   ├── booking_page.dart
│   │   │   │   └── qr_entry_page.dart
│   │   │   ├── active_parking/
│   │   │   │   ├── active_parking_page.dart
│   │   │   │   └── widgets/
│   │   │   │       └── stopwatch_widget.dart
│   │   │   ├── payment/
│   │   │   │   ├── payment_page.dart
│   │   │   │   ├── qris_payment_page.dart
│   │   │   │   └── exit_qr_page.dart
│   │   │   ├── history/
│   │   │   │   ├── history_page.dart
│   │   │   │   └── history_detail_page.dart
│   │   │   └── profile/
│   │   │       ├── profile_page.dart
│   │   │       └── edit_profile_page.dart
│   │   ├── operator/
│   │   │   ├── registration/
│   │   │   │   └── operator_register_page.dart
│   │   │   ├── dashboard/
│   │   │   │   ├── operator_dashboard_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── stats_row_widget.dart
│   │   │   │       └── active_vehicle_card.dart
│   │   │   ├── scanner/
│   │   │   │   └── qr_scanner_page.dart
│   │   │   ├── vehicle_detail/
│   │   │   │   └── scanned_vehicle_page.dart
│   │   │   └── lot_management/
│   │   │       ├── lot_management_page.dart
│   │   │       └── add_edit_lot_page.dart
│   │   └── admin/
│   │       ├── admin_dashboard_page.dart
│   │       ├── approval_list_page.dart
│   │       └── approval_detail_page.dart
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_bottom_nav.dart
│       ├── loading_overlay.dart
│       ├── empty_state_widget.dart
│       ├── status_badge.dart
│       ├── qr_display_card.dart
│       └── vehicle_card_widget.dart
│
└── injection/
    └── injection_container.dart
```

### File Konfigurasi Tambahan

| File | Keterangan |
|---|---|
| `android/app/google-services.json` | Google Maps & FCM Android |
| `ios/Runner/GoogleService-Info.plist` | Google Maps & FCM iOS |
| `.env` | API keys (Supabase URL, anon key, payment key) |
| `assets/images/` | Gambar lokal (logo, ilustrasi empty state) |
| `assets/animations/` | File Lottie JSON (loading, success, dll) |

---

## 8. Dependensi (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5

  # Routing
  go_router: ^12.0.0

  # Supabase
  supabase_flutter: ^2.3.0

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # UI
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5

  # Image
  image_picker: ^1.0.4

  # Utils
  intl: ^0.19.0
  uuid: ^4.2.1
  permission_handler: ^11.0.1
```

---

## 9. Langkah Pembuatan Aplikasi

### Tahap 1 — Setup & Fondasi (Minggu 1–2)

1. Buat project Flutter: `flutter create parqr`
2. Setup Supabase project: buat database, auth, storage
3. Jalankan SQL migration untuk semua tabel (lihat ERD)
4. Setup folder structure sesuai diagram di atas
5. Konfigurasi `go_router` dengan route guards berdasarkan role
6. Implementasi dark theme di `app_theme.dart`
7. Setup dependency injection dengan `get_it`
8. Buat semua widget shared: AppButton, AppTextField, StatusBadge, dll

### Tahap 2 — Autentikasi & Profil (Minggu 2–3)

1. Implementasi AuthBloc: login, register, logout
2. Halaman Login, Register, Forgot Password
3. Flow onboarding: `complete_profile_page` → `add_vehicle_page`
4. Upload foto kendaraan ke Supabase Storage
5. Simpan data ke tabel `users` dan `vehicles`

### Tahap 3 — User Flow Parkir (Minggu 3–5)

1. Halaman Home: fetch dan tampilkan daftar lahan parkir
2. Integrasi Google Maps (dark mode tiles)
3. Halaman detail parkir + informasi slot/lantai
4. Flow booking: pilih kendaraan → konfirmasi → generate QR
5. QR Code entry page (`qr_flutter`)
6. Halaman Active Parking + stopwatch real-time (Timer + BLoC)
7. Logic stopwatch tetap jalan saat user klik Keluar Parkir

### Tahap 4 — Pembayaran (Minggu 5–6)

1. Halaman Payment: pilih Cash vs QRIS
2. Flow Cash: kirim notifikasi ke operator → tunggu verifikasi
3. Flow QRIS: panggil payment gateway → tampilkan QRIS + countdown
4. Webhook Supabase untuk update status pembayaran
5. Generate exit QR Code setelah pembayaran berhasil
6. Halaman konfirmasi keluar + QR exit

### Tahap 5 — Fitur Operator (Minggu 6–8)

1. Form pendaftaran operator (`operator_register_page`)
2. Operator dashboard: stats + list kendaraan aktif
3. QR Scanner (`mobile_scanner`) untuk scan masuk/keluar
4. Halaman detail kendaraan setelah scan
5. UI verifikasi pembayaran cash
6. CRUD manajemen lahan parkir
7. Supabase Realtime untuk update data kendaraan live

### Tahap 6 — Fitur Admin (Minggu 8–9)

1. Login admin dengan route guard khusus
2. Halaman daftar pengajuan operator
3. Detail pengajuan + Approve/Reject
4. Sistem kirim email otomatis dengan akun operator baru
5. Dashboard statistik global

### Tahap 7 — Polish & QA (Minggu 9–10)

1. Implementasi error handling menyeluruh
2. Notifikasi push (FCM) untuk user & operator
3. Animasi & transisi halaman
4. Loading skeleton untuk semua list
5. Empty state yang informatif
6. Unit test untuk semua usecase
7. Widget test untuk komponen kritis
8. Build APK (Android) & IPA (iOS) untuk testing

---

## 10. ERD — Penjelasan Tabel & Relasi

### Tabel Inti

| Tabel | Fungsi |
|---|---|
| `users` | Semua pengguna app (visitor, operator, admin). Field `role` membedakan akses |
| `vehicles` | Data kendaraan milik user. Satu user bisa punya banyak kendaraan |
| `parking_lots` | Data lahan parkir milik operator. Berisi nama, koordinat, kapasitas, tarif |
| `parking_slots` | Detail slot/petak per lahan parkir. Masing-masing punya kode, lantai, status |
| `parking_sessions` | Inti transaksi: rekam tiap kendaraan masuk-keluar. Berisi QR codes, timestamp, lokasi |
| `payments` | Data pembayaran per sesi. Metode, status, referensi QRIS, deadline |
| `operator_verifications` | Log verifikasi cash payment oleh operator |
| `operator_registrations` | Pengajuan pendaftaran operator, lengkap dengan status approve/reject |
| `notifications` | Notifikasi in-app per user: booking, pembayaran, dll |

### Relasi Kunci

- `users` (1) → `vehicles` (many): satu user punya banyak kendaraan
- `users` (1) → `parking_lots` (many): satu operator punya banyak lahan
- `parking_lots` (1) → `parking_slots` (many): satu lahan punya banyak slot
- `parking_sessions` (1) → `payments` (1): satu sesi satu pembayaran
- `payments` (1) → `operator_verifications` (0..1): cash payment butuh verifikasi

> **💡 Catatan Implementasi:** Gunakan Supabase Row Level Security (RLS) untuk memastikan operator hanya bisa akses data lahan miliknya, dan user hanya bisa akses sesi parkirnya sendiri. Admin memiliki bypass policy khusus.

---

## 11. Stitch Design Prompt

Salin prompt berikut ke [stitch.withgoogle.com](https://stitch.withgoogle.com):

```
Design a professional dark-themed mobile parking management app called "ParQr".
The visual language is: dark modern, futuristic, clean, professional.

COLOR PALETTE:
- Background primary: #0D1117
- Background card: #161B22
- Background elevated: #1C232C
- Accent blue: #00C2FF
- Accent purple: #7B61FF
- Success green: #00D68F
- Warning orange: #FF8C42
- Text primary: #E8EDF3
- Text secondary: #8B949E
- Border/divider: #2A3441

TYPOGRAPHY:
- Font: Inter (or SF Pro on iOS)
- Headings: Bold, white
- Body: Regular, #E8EDF3
- Caption/label: Medium, #8B949E

DESIGN ELEMENTS:
- Cards with subtle border #2A3441 and background #161B22
- Rounded corners: 12-16px for cards, 8px for buttons
- Neon-like accent glows (very subtle, 0.15 opacity)
- Bottom navigation bar with icon+label, dark background
- Status pills: green for active, orange for pending, red for expired
- QR code display: centered, white border glow on dark bg
- Gradient CTA buttons: left #7B61FF to right #00C2FF
- Maps: dark map tiles (Google Maps night mode or Mapbox dark)

SCREENS TO DESIGN — USER (VISITOR) ROLE:
1. Splash screen — app icon centered, subtle particle animation
2. Login screen — email+password fields, gradient login button, "Register" link
3. Register screen — name, email, phone, password fields
4. Profile setup screen — complete profile: name, address; vehicle: brand, model,
   license plate, vehicle type (motor/mobil), upload vehicle photo
5. Home screen — search bar "Cari tempat parkir...", nearby parking list as cards
   (each showing: name, address, distance, price/hour, availability badge),
   banner "Daftarkan lahan parkirmu!", bottom nav: Home / Riwayat / Profil
6. Parking lot detail screen — name, address, map thumbnail, capacity, price/hour,
   floor info, "Pesan Parkir" CTA button
7. Booking confirmation screen — vehicle selector, slot selector, "Konfirmasi Pemesanan" button
8. QR Code entry screen — fullscreen QR code display with parking name & time below,
   "Simpan Lokasi Kendaraan" button, status: "Menunggu scan operator"
9. Active parking screen — running stopwatch (large, center), vehicle info,
   saved location map pin, "Keluar Parkir" red button at bottom
10. Payment screen — amount due (large), payment method selector (Cash / QRIS),
    countdown timer 10:00 for QRIS, "Bayar" button
11. Exit QR Code screen — success state, green checkmark, QR code for exit scan,
    transaction summary
12. History screen — list of past sessions with date, location, duration, amount, status badge

SCREENS TO DESIGN — OPERATOR ROLE:
13. Operator registration form — company name, address, lot size, floors, capacity,
    photo upload, "Ajukan Pendaftaran" button
14. Operator dashboard — stats row: (Kendaraan Masuk / Aktif / Pendapatan hari ini),
    live list of parked vehicles (plate, name, time in, floor), "Scan QR" FAB button
15. QR Scanner screen — camera viewfinder, dark overlay, scan frame, status text
16. Vehicle detail card (after scan) — vehicle photo, name, plate, check-in time,
    floor/slot, verify payment button
17. Payment verification modal — for cash: "Konfirmasi Pembayaran Tunai" with
    amount and "Verifikasi" button
18. Lot settings screen — edit name, capacity, rates, floor layout CRUD

SCREENS TO DESIGN — ADMIN ROLE:
19. Admin dashboard — stats: total operators, pending approvals, active sessions today
20. Operator approval list — cards with company name, owner, submission date,
    status (Pending/Approved/Rejected), "Review" button
21. Approval detail screen — all operator info, map pin for address,
    "Approve" (green) and "Reject" (red) buttons, reject reason text input

COMPONENT LIBRARY EXTRAS:
- Empty state illustration (no parking found, no history)
- Loading skeleton for parking cards
- Toast notifications (success/error/info)
- Bottom sheet for vehicle/slot selection
- Stopwatch component with large digits
- QR code card component
```

---

*ParQr — Dokumentasi PRD v1.0.0 | Dibuat untuk keperluan pengembangan internal*
