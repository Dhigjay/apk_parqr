# Dokumentasi Skema Database ParQr

Dokumentasi ini menjelaskan struktur tabel utama pada database PostgreSQL di Supabase.

## 1. Tabel Utama

### `users`
Tabel yang di-sinkronisasi dengan `auth.users` Supabase. Berisi data profil semua aktor sistem.
- `id` (UUID): Primary key.
- `email`, `full_name`, `phone`, `address`: Data profil dasar.
- `role`: (`user`, `operator`, `admin`).
- `profile_completed`: Boolean penanda status *onboarding*.

### `vehicles`
Kendaraan yang didaftarkan oleh pengguna umum (pengunjung).
- `user_id` (UUID): Relasi ke tabel `users`.
- `brand`, `model`, `plate_number`: Detail kendaraan.
- `vehicle_type`: Enum string (`motor` atau `mobil`).

### `operator_registrations`
Pendaftaran dari `user` biasa untuk menjadi `operator`.
- `applicant_user_id`: ID pengaju.
- `business_name`, `address`, `latitude`, `longitude`: Lokasi lahan.
- `floors`, `total_capacity`, `price_per_hour`: Spesifikasi lahan.
- `status`: (`pending`, `approved`, `rejected`).
- `reject_reason`: Alasan admin jika status ditolak.

### `parking_lots` & `parking_slots`
Lahan parkir aktif dan detail tempat per lantai.
- `parking_lots`: Dimiliki oleh `operator_id`. Menampung kapasitas total.
- `parking_slots`: Anak dari `parking_lots`, merepresentasikan satu titik parkir (opsional, untuk sistem yang memiliki mapping visual/lantai spesifik).

### `parking_sessions`
Transaksi inti. Mencatat *lifecycle* parkir kendaraan.
- `user_id`, `vehicle_id`, `lot_id`.
- `status`: Lifecycle transaksi (`booked`, `active`, `payment_pending`, `paid`, `completed`, dsb).
- `entry_qr_token` & `exit_qr_token`: String unik untuk barcode masuk dan keluar.
- `entered_at`, `exited_at`: Timestamp.

### `payments` & `operator_verifications`
Tabel finansial transaksi.
- `payments`: Relasi 1-to-1 dengan `parking_sessions`. Berisi `amount`, `method` (cash/qris), `status`.
- `operator_verifications`: Log manual yang dicatat ketika metode pembayaran *cash* disetujui (diverifikasi) oleh operator di pos keluar.

### `audit_logs` (Baru di Sprint 6)
Catatan kejadian krusial (seperti login operator, modifikasi payment, dsb).
- `user_id`: Aktor yang melakukan.
- `action`: Nama kegiatan (misal: `qris_payment_verified`).
- `entity_type` & `entity_id`: Data yang terpengaruh.
- `metadata`: JSON untuk nilai tambahan bebas.

## 2. Row Level Security (RLS)
Sistem ini menggunakan RLS untuk membatasi ruang lingkup pembacaan dan penulisan:
1. **Admins (`public.is_admin()` = true)**: Dapat mengakses (BACA/TULIS) semua data.
2. **Operators (`role` = 'operator')**: Hanya dapat membaca/menulis `parking_lots`, `parking_slots`, `parking_sessions`, dan verifikasi pembayaran yang terhubung dengan `auth.uid()` miliknya.
3. **Users**: Hanya dapat membaca/menulis `vehicles`, sesi, dan pembayaran milik mereka sendiri.

> [!NOTE]
> Pemanggilan ke sistem krusial (seperti membuat user baru, validasi payment gateway) dilakukan via **Edge Functions** di sisi server Supabase yang menggunakan `SERVICE_ROLE_KEY` agar dapat mem-bypass RLS.
