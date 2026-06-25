# Review Row Level Security (RLS) ParQr

Tanggal Review: 18 Juni 2026

## Ringkasan Eksekutif
Secara keseluruhan, tabel-tabel utama di dalam sistem ParQr telah dilindungi dengan **Row Level Security (RLS)** dengan baik melalui file `20260611160000_initial_schema.sql`. Kebijakan dasar untuk peran *admin*, *operator*, dan *user* umum sudah diimplementasikan sedemikian rupa sehingga mencegah kebocoran data.

Namun, terdapat redundansi dan konflik minor pada file migrasi `20260617_sprint2_rls.sql` yang berpotensi menyebabkan error jika dijalankan ulang, dikarenakan perbedaan penamaan kolom.

## Detail Review per Tabel

### 1. `users`
- **Read**: User dapat melihat profilnya sendiri atau admin melihat semua.
- **Update**: User dapat memperbarui profilnya sendiri atau admin.
- **Insert**: User dapat membuat data profil dengan UID yang sesuai.
- **Status**: ✅ Aman.

### 2. `vehicles`
- **Read/Write**: Dibatasi hanya untuk `user_id = auth.uid()` atau admin.
- **Status**: ✅ Aman.

### 3. `operator_registrations`
- **Read/Write**: Dibatasi untuk `applicant_user_id = auth.uid()` atau admin.
- **Status**: ✅ Aman.

### 4. `parking_lots`
- **Read**: Semua user terautentikasi dapat melihat lahan yang `is_active = true`, operator dapat melihat lahan miliknya sendiri, dan admin dapat melihat semua.
- **Write**: Hanya operator pemilik dan admin yang dapat melakukan modifikasi.
- **Status**: ✅ Aman. Redundansi pada `20260617_sprint2_rls.sql` di mana kebijakan "Anyone can view parking lots" ditambahkan ulang tanpa mengecek status aktif. Disarankan menggunakan kebijakan dari `initial_schema.sql` saja.

### 5. `parking_slots`
- **Read**: Hanya lot yang aktif yang slotnya dapat dilihat oleh pengguna umum. Operator dapat melihat seluruh slot di lot miliknya.
- **Write**: Hanya operator pemilik dan admin.
- **Status**: ✅ Aman.

### 6. `parking_sessions`
- **Read/Write**: Hanya user pemilik sesi, operator pada lahan tempat sesi tersebut berlangsung, atau admin yang memiliki hak akses.
- **Status**: ⚠️ **Conflict Detected**. Di file `20260617_sprint2_rls.sql`, ada upaya penambahan RLS dengan memanggil kolom `parking_lot_id`, padahal nama kolom asli di tabel adalah `lot_id`. Karena `initial_schema.sql` sudah menangani RLS untuk tabel ini secara ekstensif menggunakan `lot_id`, maka deklarasi pada sprint 2 dapat diabaikan atau dihapus untuk mencegah error saat deployment.

### 7. `payments` & `operator_verifications`
- **Read/Write**: Akses update/insert terbatas sesuai logika hierarki: User dapat membuat `payment` untuk sesinya, operator/admin dapat memodifikasi (untuk verifikasi).
- **Status**: ✅ Aman.

## Rekomendasi
1. Abaikan/hapus file migrasi `20260617_sprint2_rls.sql` karena instruksi di dalamnya sudah tercakup dengan lebih baik dan bebas *typo* pada `initial_schema.sql`.
2. Semua *insert* dari backend (seperti webhook) harus menggunakan `SERVICE_ROLE_KEY` agar mem-bypass RLS karena klien dari webhook bukanlah *authenticated user*. Ini telah diterapkan dengan benar di dalam *Edge Function*.
