# Tasklist Pengembangan ParQr

Tanggal dibuat: 2026-06-11  
Sumber acuan: `PRD.md` dan inspeksi struktur/kode proyek Flutter saat ini.

## Ringkasan Produk

ParQr adalah aplikasi manajemen parkir modern berbasis Flutter untuk Android dan iOS. Backend memakai Supabase untuk Auth, PostgreSQL, Storage, Realtime, dan integrasi pembayaran QRIS/payment gateway. MVP memiliki 3 role utama:

- Pengunjung: registrasi, profil, kendaraan, cari lahan parkir, booking, QR masuk, stopwatch tarif, pembayaran, QR keluar, riwayat.
- Operator/Pemilik Lahan: daftar lahan, dashboard, scan QR masuk/keluar, verifikasi cash, kelola lahan dan slot.
- Admin: review pengajuan operator, approve/reject, buat akun operator, lihat data dan statistik global.

## Kondisi Repo Saat Ini

Yang sudah ada:

- Project Flutter multi-platform sudah dibuat.
- Dependency utama di `pubspec.yaml` sudah mengikuti PRD: `flutter_bloc`, `go_router`, `supabase_flutter`, `get_it`, `qr_flutter`, `mobile_scanner`, `image_picker`, dan utilitas lain.
- Fondasi tema gelap sudah ada di `lib/core/theme/app_theme.dart`.
- Warna, teks, dan text style awal sudah ada di `lib/core/constants`.
- Router awal sudah ada untuk splash, login, dan home.
- Halaman awal sudah ada: splash, login placeholder, home placeholder.
- Auth BLoC awal sudah ada: event login/register/logout/check status dan state dasar.
- Interface auth repository sudah ada.
- Dependency injection awal sudah dibuat dengan `get_it`.

Masalah/gap yang perlu diprioritaskan:

- `lib/injection/injection_container.dart` mengimpor file yang belum ada: `auth_remote_ds.dart` dan `auth_repo_impl.dart`.
- Import package belum konsisten: ada `package:apk_parqr/...`, padahal nama package di `pubspec.yaml` adalah `parqr`.
- Login masih bypass langsung ke home dan belum memakai form/BLoC.
- Route guard berdasarkan role belum ada.
- Folder `data/models` dan `data/repositories` ada, tetapi belum berisi implementasi.
- Domain entities, usecases, datasource lain, shared widgets, halaman register/onboarding/parking/payment/operator/admin belum dibuat.
- Asset folder sudah dideklarasikan, tetapi belum ada asset.
- `README.md` masih template bawaan Flutter.
- `flutter analyze` dan `dart analyze lib` dicoba, tetapi timeout. Perlu dicoba ulang setelah blocker compile dibereskan.

## Pembagian Peran Tim

- Maulana Dhigjay: Backend, database, Supabase, repository/data layer, payment, security.
- Afif Abdilah: Tampilan/UI/UX Flutter, design system, halaman dan widget.
- Shandy Satria: Integrasi mobile, routing, state management, QR/location/realtime, QA, build release.

## Sprint 0 - Stabilkan Fondasi Project

Target: project bisa dianalisis dan dijalankan tanpa error compile dasar.

### Maulana Dhigjay

- [ ] Buat `lib/data/datasources/remote/auth_remote_ds.dart`.
- [ ] Buat `lib/data/repositories/auth_repo_impl.dart`.
- [ ] Implementasikan login, register, logout, forgot password menggunakan Supabase Auth.
- [ ] Pastikan `AuthRepositoryImpl` memenuhi kontrak `IAuthRepository`.
- [ ] Siapkan struktur awal folder backend sesuai PRD:
  - `lib/data/datasources/remote`
  - `lib/data/datasources/local`
  - `lib/data/models`
  - `lib/data/repositories`
  - `lib/domain/entities`
  - `lib/domain/usecases`
- [ ] Susun draft SQL migration Supabase untuk tabel inti: `users`, `vehicles`, `parking_lots`, `parking_slots`, `parking_sessions`, `payments`, `operator_verifications`, `operator_registrations`, `notifications`.

### Afif Abdilah

- [ ] Rapikan nama aplikasi di UI dari placeholder menjadi `ParQr`.
- [ ] Buat shared widget awal:
  - `AppButton`
  - `AppTextField`
  - `StatusBadge`
  - `LoadingOverlay`
  - `EmptyStateWidget`
  - `QrDisplayCard`
  - `VehicleCardWidget`
  - `AppBottomNav`
- [ ] Ubah halaman login dari tombol bypass menjadi layout form lengkap.
- [ ] Siapkan layout register dan forgot password.
- [ ] Tambahkan placeholder asset/logo ParQr di `assets/images`.
- [ ] Pastikan tema mengikuti PRD: dark background, card gelap, accent blue/purple, CTA gradient.

### Shandy Satria

- [ ] Betulkan semua import package agar konsisten dengan nama package `parqr`.
- [ ] Daftarkan route awal untuk register, forgot password, complete profile, add vehicle, home, history, profile.
- [ ] Tambahkan `BlocProvider` untuk `AuthBloc` pada level aplikasi atau route yang relevan.
- [ ] Buat route guard awal:
  - user belum login diarahkan ke login
  - user login diarahkan sesuai role
  - role operator/admin tidak bisa masuk halaman user yang tidak sesuai
- [ ] Jalankan ulang `flutter analyze` setelah blocker import dibereskan.
- [ ] Dokumentasikan cara menjalankan app dengan `--dart-define` atau `--dart-define-from-file`.

## Sprint 1 - Autentikasi, Profil, dan Kendaraan

Target: user bisa daftar, login, melengkapi profil, dan menambah kendaraan.

### Maulana Dhigjay

- [ ] Buat model/entity `User`, `Vehicle`, dan mapping `fromJson/toJson`.
- [ ] Buat repository interface dan implementation untuk user dan vehicle.
- [ ] Implementasikan Supabase table access untuk profil user.
- [ ] Implementasikan CRUD kendaraan.
- [ ] Buat upload foto kendaraan ke Supabase Storage.
- [ ] Buat RLS policy agar user hanya bisa membaca/mengubah data miliknya.
- [ ] Buat seed data minimal untuk role admin dan sample user bila diperlukan.

### Afif Abdilah

- [ ] Buat halaman `register_page.dart` sesuai PRD: nama, email, phone, password.
- [ ] Buat halaman `forgot_password_page.dart`.
- [ ] Buat halaman `complete_profile_page.dart`: nama lengkap dan alamat.
- [ ] Buat halaman `add_vehicle_page.dart`: merk, model, jenis, nomor polisi, upload foto.
- [ ] Tambahkan validasi visual pada field wajib.
- [ ] Buat state loading, error, success untuk semua form.

### Shandy Satria

- [ ] Hubungkan form login/register/forgot password ke `AuthBloc`.
- [ ] Buat `ProfileCubit` dan `VehicleCubit`.
- [ ] Atur flow setelah register: login/register sukses -> complete profile -> add vehicle -> home.
- [ ] Tambahkan validasi client-side untuk email, password, nomor HP, nomor polisi.
- [ ] Buat unit test dasar untuk auth bloc/cubit.
- [ ] Buat widget test untuk login/register form.

## Sprint 2 - User Flow Parkir

Target: pengunjung bisa mencari lahan parkir, melihat detail, booking, dan mendapatkan QR masuk.

### Maulana Dhigjay

- [ ] Buat model/entity `ParkingLot`, `ParkingSlot`, dan `ParkingSession`.
- [ ] Buat repository parking lot untuk search, detail, slot tersedia, dan filter.
- [ ] Buat repository parking session untuk booking dan generate session.
- [ ] Definisikan payload QR masuk berisi minimal: `session_id`, `type`, `issued_at`, `expires_at`, dan nonce/signature server-side.
- [ ] Tambahkan validasi QR expired setelah 24 jam bila belum dipakai.
- [ ] Buat RLS policy untuk sesi parkir user dan operator.

### Afif Abdilah

- [ ] Buat home screen lengkap:
  - search bar
  - banner daftar lahan
  - list parking card
  - bottom navigation Home/Riwayat/Profil
- [ ] Buat `parking_card_widget.dart`.
- [ ] Buat halaman detail parkir: nama, alamat, kapasitas, tarif, lantai, map thumbnail.
- [ ] Buat halaman booking: pilih kendaraan, pilih slot/lantai, konfirmasi.
- [ ] Buat halaman QR entry: QR besar, nama parkir, waktu, status menunggu scan operator.
- [ ] Buat komponen loading skeleton dan empty state untuk hasil pencarian.

### Shandy Satria

- [ ] Buat `ParkingSessionBloc`.
- [ ] Hubungkan home/detail/booking/QR entry dengan repository Maulana.
- [ ] Integrasikan `qr_flutter` untuk QR masuk.
- [ ] Tambahkan permission dan utilitas lokasi untuk "Simpan Lokasi Kendaraan".
- [ ] Siapkan struktur realtime update untuk status booking/session.
- [ ] Buat test flow booking sampai QR entry.

## Sprint 3 - Active Parking dan Pembayaran

Target: stopwatch berjalan, user checkout, memilih cash/QRIS, dan mendapatkan QR keluar.

### Maulana Dhigjay

- [ ] Buat model/entity `Payment`.
- [ ] Buat repository payment untuk create payment, get status, verify cash, dan generate exit QR.
- [ ] Implementasikan kalkulasi tarif berdasarkan durasi dan tarif per jam.
- [ ] Pastikan stopwatch/tarif hanya berhenti setelah payment verified.
- [ ] Siapkan kontrak integrasi QRIS/payment gateway.
- [ ] Buat Supabase Edge Function atau endpoint webhook untuk update status QRIS.
- [ ] Buat log `operator_verifications` untuk cash payment.

### Afif Abdilah

- [ ] Buat `active_parking_page.dart` dengan stopwatch besar, info kendaraan, map pin, dan tombol keluar.
- [ ] Buat `stopwatch_widget.dart`.
- [ ] Buat payment screen: total bayar, pilihan Cash/QRIS, tombol bayar.
- [ ] Buat QRIS payment page: QRIS, countdown 10 menit, status pembayaran.
- [ ] Buat exit QR screen: success state, QR keluar, ringkasan transaksi.
- [ ] Buat history screen dan history detail screen.

### Shandy Satria

- [ ] Buat `PaymentCubit`.
- [ ] Hubungkan active parking ke session realtime.
- [ ] Implementasikan timer/stopwatch yang tahan navigasi antar halaman.
- [ ] Integrasikan polling/realtime status pembayaran.
- [ ] Integrasikan `qr_flutter` untuk QR keluar.
- [ ] Buat test perhitungan durasi dan status payment.

## Sprint 4 - Fitur Operator

Target: operator bisa daftar lahan, scan QR masuk/keluar, lihat dashboard, verifikasi cash, dan mengelola lahan.

### Maulana Dhigjay

- [ ] Buat model/entity `OperatorRegistration`.
- [ ] Buat backend flow pengajuan operator.
- [ ] Buat repository operator untuk dashboard, active vehicle list, scan check-in/check-out.
- [ ] Buat CRUD parking lot, floor, slot, tariff.
- [ ] Buat query statistik: kendaraan masuk hari ini, aktif, pendapatan hari ini.
- [ ] Buat Supabase Realtime channel untuk active sessions per operator.
- [ ] Buat RLS agar operator hanya akses lahan dan sesi miliknya.

### Afif Abdilah

- [ ] Buat halaman operator registration: nama usaha, alamat, luas, jumlah lantai, kapasitas, tarif, foto.
- [ ] Buat operator dashboard: stats row, list kendaraan aktif, scan QR FAB.
- [ ] Buat `stats_row_widget.dart`.
- [ ] Buat `active_vehicle_card.dart`.
- [ ] Buat QR scanner screen dengan viewfinder dan overlay gelap.
- [ ] Buat scanned vehicle detail page.
- [ ] Buat modal verifikasi pembayaran cash.
- [ ] Buat lot management dan add/edit lot page.

### Shandy Satria

- [ ] Integrasikan `mobile_scanner` untuk scan QR masuk/keluar.
- [ ] Buat validasi tipe QR: entry vs exit.
- [ ] Buat `OperatorDashboardCubit`.
- [ ] Hubungkan dashboard operator dengan realtime sessions.
- [ ] Hubungkan verifikasi cash ke payment repository.
- [ ] Tambahkan error handling saat QR invalid, expired, atau bukan milik operator.
- [ ] Buat integration test alur scan masuk dan scan keluar.

## Sprint 5 - Fitur Admin

Target: admin bisa mengelola approval operator dan melihat statistik global.

### Maulana Dhigjay

- [ ] Buat repository admin untuk daftar pengajuan operator.
- [ ] Implementasikan approve operator:
  - update status pengajuan
  - buat akun operator
  - hubungkan operator dengan parking lot
  - kirim email kredensial atau reset link
- [ ] Implementasikan reject operator dengan alasan wajib.
- [ ] Buat query statistik global aplikasi.
- [ ] Buat RLS/admin policy khusus untuk akses semua data.

### Afif Abdilah

- [ ] Buat admin dashboard page.
- [ ] Buat approval list page dengan status Pending/Approved/Rejected.
- [ ] Buat approval detail page dengan detail usaha, foto, alamat/map pin.
- [ ] Buat form alasan reject.
- [ ] Buat state empty/loading/error untuk list approval.

### Shandy Satria

- [ ] Buat route guard admin.
- [ ] Buat cubit/bloc admin approval.
- [ ] Hubungkan approve/reject ke repository admin.
- [ ] Tambahkan konfirmasi dialog sebelum approve/reject.
- [ ] Buat widget test untuk approval list dan approval detail.

## Sprint 6 - Polish, QA, dan Release

Target: MVP siap diuji sebagai APK internal.

### Maulana Dhigjay

- [ ] Review semua RLS policy.
- [ ] Tambahkan audit logging untuk event penting: login operator, scan QR, verify payment, approval admin.
- [ ] Pastikan payment webhook aman dan idempotent.
- [ ] Buat backup script atau dokumentasi export database.
- [ ] Tambahkan dokumentasi schema database.

### Afif Abdilah

- [ ] Polish spacing, typography, contrast, dan responsive layout untuk layar 5 sampai 6.7 inci.
- [ ] Tambahkan animasi transisi yang ringan.
- [ ] Buat toast/snackbar success, error, info.
- [ ] Buat empty state yang konsisten.
- [ ] Pastikan semua text tidak overflow.
- [ ] Siapkan asset final: logo, ilustrasi empty state, loading/success animation bila ada.

### Shandy Satria

- [ ] Jalankan `flutter analyze` sampai clean atau semua issue penting tercatat.
- [ ] Jalankan `flutter test`.
- [ ] Buat integration test untuk flow utama:
  - register/login
  - tambah kendaraan
  - booking sampai QR masuk
  - scan operator
  - payment cash
  - QR keluar
- [ ] Siapkan `.env.example`.
- [ ] Perbarui `README.md` dengan setup, env, run command, dan build command.
- [ ] Build APK debug/internal testing.
- [ ] Catat bug hasil QA ke backlog.

## Kontrak Antar Tim

- Maulana menyediakan kontrak repository dan model sebelum Afif/Shandy mengunci UI flow.
- Afif boleh memakai mock data sementara, tetapi struktur field harus mengikuti model dari Maulana.
- Shandy bertanggung jawab menghapus mock data saat endpoint/repository sudah siap.
- Semua fitur baru harus punya loading, success, error, dan empty state.
- Semua route baru harus didaftarkan di `RouteNames` dan `AppRouter`.
- Jangan commit API key asli. Gunakan `.env` lokal dan `.env.example` untuk dokumentasi.
- Setelah menambah dependency, jalankan `flutter pub get` dan catat perubahan `pubspec.lock`.

## Prioritas Terdekat

1. Perbaiki compile blocker: file auth datasource/repository yang hilang dan import package yang salah.
2. Selesaikan auth flow nyata: login, register, logout, forgot password.
3. Buat halaman auth/onboarding agar user bisa masuk ke flow aplikasi.
4. Buat schema Supabase dan RLS awal.
5. Baru lanjut ke parking lot, booking, QR, payment, operator, dan admin.

## Definition of Done MVP

- User bisa daftar, login, lengkapi profil, tambah kendaraan.
- User bisa melihat daftar parkir, booking, menerima QR masuk.
- Operator bisa scan QR masuk dan memulai sesi parkir.
- Stopwatch dan tarif berjalan sesuai waktu masuk.
- User bisa checkout dengan cash atau QRIS.
- Operator bisa verifikasi cash.
- User menerima QR keluar setelah payment verified.
- Operator bisa scan QR keluar dan menutup sesi.
- Admin bisa approve/reject pengajuan operator.
- App lolos `flutter analyze`, `flutter test`, dan build APK internal.
