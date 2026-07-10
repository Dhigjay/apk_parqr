# ✅ Onboarding Flow Fix - ParQr

## 🔧 Masalah yang Diperbaiki

### **Masalah Awal:**
1. ❌ Setelah register → langsung ke Home (bypass complete profile)
2. ❌ Complete Profile Page → tidak menyimpan ke database (hanya simulasi)
3. ❌ Add Vehicle Page → tidak menyimpan ke database (hanya simulasi)
4. ❌ Payment error: "User profile belum lengkap"

### **Root Cause:**
- Register page redirect langsung ke `/home`
- Complete Profile dan Add Vehicle hanya mock/simulasi
- Data tidak tersimpan ke tabel `users` dan `vehicles`

---

## ✅ Solusi yang Diterapkan

### **1. Fix Register Redirect** ✅
**File**: `lib/presentation/pages/auth/register_page.dart`

**Perubahan**:
```dart
// BEFORE:
if (state is AuthAuthenticated) {
  context.go('/home');  // ← Langsung ke home
}

// AFTER:
if (state is AuthAuthenticated) {
  context.go('/complete-profile');  // ← Ke complete profile dulu
}
```

---

### **2. Fix Complete Profile - Save to Database** ✅
**File**: `lib/presentation/pages/onboarding/complete_profile_page.dart`

**Perubahan**:
- ✅ Tambah `ProfileCubit` integration
- ✅ Call `profileCubit.completeProfile()` yang menyimpan ke database
- ✅ Redirect ke `/add-vehicle` setelah sukses
- ✅ Error handling dengan snackbar

**File**: `lib/presentation/blocs/profile/profile_state.dart`
- ✅ Tambah state baru: `ProfileCompleted` untuk onboarding flow

**File**: `lib/presentation/blocs/profile/profile_cubit.dart`
- ✅ Update `completeProfile()` emit `ProfileCompleted` instead of `ProfileLoaded`

---

### **3. Fix Add Vehicle - Save to Database** ✅
**File**: `lib/presentation/pages/onboarding/add_vehicle_page.dart`

**Perubahan**:
- ✅ Tambah `VehicleCubit` integration
- ✅ Call `vehicleCubit.addVehicle()` yang menyimpan ke database
- ✅ Redirect ke `/home` setelah sukses
- ✅ Error handling dengan snackbar

**File**: `lib/presentation/blocs/vehicle/vehicle_cubit.dart`
- ✅ Update `addVehicle()` call repository
- ✅ Emit `VehicleAdded` setelah sukses

**File**: `lib/presentation/blocs/vehicle/vehicle_state.dart`
- ✅ Tambah alias `VehicleAdded` untuk consistency

---

## 🎯 Flow Baru (Benar)

```
User Register
  ↓
✅ Redirect ke /complete-profile
  ↓
User isi nama & alamat → Klik "Simpan & Lanjut Tambah Kendaraan"
  ↓
✅ Data tersimpan ke tabel `users` di database
✅ Snackbar: "Profil berhasil disimpan!"
  ↓
✅ Redirect ke /add-vehicle
  ↓
User isi merk, model, jenis, nomor polisi → Klik "Simpan & Masuk ke Home"
  ↓
✅ Data tersimpan ke tabel `vehicles` di database
✅ Snackbar: "Kendaraan berhasil ditambahkan!"
  ↓
✅ Redirect ke /home
  ↓
🎉 User bisa checkout parkir dan payment tanpa error!
```

---

## 🧪 Cara Test

### **Test Flow Lengkap:**

1. **Run aplikasi**:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

2. **Register akun baru**:
   - Klik "Daftar"
   - Isi: Nama, Email, No HP, Password
   - Klik "Daftar"
   - **Harusnya redirect ke halaman "Lengkapi Profil"** ✅

3. **Lengkapi Profil**:
   - Isi: Nama lengkap, Alamat
   - Klik "Simpan & Lanjut Tambah Kendaraan"
   - **Harusnya muncul snackbar hijau "Profil berhasil disimpan!"** ✅
   - **Harusnya redirect ke halaman "Tambahkan Kendaraan"** ✅

4. **Tambah Kendaraan**:
   - Isi: Merk (Toyota), Model (Avanza), Jenis (Mobil), No Polisi (B 1234 XYZ)
   - Klik "Simpan & Masuk ke Home"
   - **Harusnya muncul snackbar hijau "Kendaraan berhasil ditambahkan!"** ✅
   - **Harusnya redirect ke Home** ✅

5. **Test Payment**:
   - Di Home → Pilih parkir → Booking → Checkout
   - Klik "Keluar Parkir" → Pilih "QRIS"
   - Klik "Bayar Sekarang"
   - **Harusnya QR Code muncul (tidak error "User profile belum lengkap")** ✅

---

## 📋 Checklist Setelah Fix

Cek di database setelah complete onboarding:

### **Tabel `users`**
1. Buka [Supabase Table Editor](https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/editor)
2. Pilih tabel `users`
3. **Harusnya ada row baru** dengan:
   - `id` = User ID dari Auth
   - `email` = Email yang didaftarkan
   - `full_name` = Nama yang diisi di complete profile
   - `address` = Alamat yang diisi
   - `role` = `user`

### **Tabel `vehicles`**
1. Pilih tabel `vehicles`
2. **Harusnya ada row baru** dengan:
   - `user_id` = User ID yang sama
   - `brand` = Merk yang diisi
   - `model` = Model yang diisi
   - `vehicle_type` = Jenis yang dipilih (motor/mobil)
   - `plate_number` = Nomor polisi yang diisi
   - `is_primary` = `true`

---

## 🐛 Troubleshooting

### **Problem: Masih error "User profile belum lengkap"**

**Cek**:
1. Apakah user benar-benar sudah complete profile?
2. Buka Supabase Table Editor → tabel `users`
3. Cari user dengan `id` = User ID yang login
4. **Jika tidak ada** → Profil belum tersimpan, coba complete profile lagi

**Fix**:
- Logout → Register ulang → Ikuti flow lengkap
- Atau manual insert via SQL (lihat `quick_insert_user.sql`)

### **Problem: "Gagal menambahkan kendaraan"**

**Cek**:
1. Console output di Flutter
2. Apakah ada error message spesifik?

**Common errors**:
- Foreign key constraint: User belum ada di tabel `users`
- Invalid vehicle type: Harus `motor` atau `mobil` (lowercase)

### **Problem: Masih redirect ke home setelah register**

**Cek**:
- Apakah kode `register_page.dart` sudah di-update?
- Coba hot restart (bukan hot reload): `r` di terminal Flutter

---

## 📞 Need Help?

Jika setelah fix ini masih ada masalah:

1. **Screenshot**:
   - Halaman yang error
   - Console output Flutter
   - Database table (users & vehicles)

2. **Test manual**:
   - Logout → Register baru → Screenshot tiap step

3. **Cek logs**:
   - Flutter console output
   - Supabase logs (jika ada error dari backend)

---

## 🎉 Summary

**Yang Diperbaiki**:
- ✅ Register → Complete Profile (bukan langsung Home)
- ✅ Complete Profile menyimpan ke database `users`
- ✅ Add Vehicle menyimpan ke database `vehicles`
- ✅ Payment tidak error lagi

**Next Step**:
1. Run aplikasi
2. Register akun baru
3. Ikuti flow onboarding lengkap
4. Test payment → QR Code harus muncul! 🚀

---

**Last Updated**: 2026-07-10  
**Status**: ✅ Fixed  
**Files Changed**: 5 files (register_page, complete_profile_page, add_vehicle_page, profile_cubit/state, vehicle_cubit/state)
