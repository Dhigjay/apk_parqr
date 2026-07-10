# 🚨 Payment Troubleshooting Guide - ParQr

## Masalah yang Anda Alami

Berdasarkan screenshot, ada 2 masalah:

### ❌ Masalah 1: Database Foreign Key Error
```
PostgrestException(message: insert or update on table "vehicles" 
violates foreign key constraint "vehicles_user_id_fkey", 
code: 23503, details: Key is not present in table "users", hint: null)
```

**Root Cause**: User ID dari Auth tidak ada di tabel `users`

**Solusi**: ✅ Sudah diperbaiki di `payment_cubit.dart`
- Sekarang akan cek user existence sebelum insert vehicle
- Jika user belum ada di tabel users, akan muncul error yang jelas

**Action Required**: 
- Pastikan user sudah lengkapi profil via halaman `complete_profile_page` sebelum checkout
- Atau manual insert user ke tabel `users` jika testing

---

### ❌ Masalah 2: QR Code / VA Number Tidak Muncul

**Symptom**: 
- Klik "Bayar QRIS" → loading terus → QR tidak muncul
- Klik "Bayar VA" → loading terus → nomor VA tidak muncul

**Root Cause**: **MIDTRANS_SERVER_KEY** belum di-set di Supabase Edge Function Environment

**Solusi**: 

#### Step 1: Dapatkan Midtrans Server Key

1. Login ke [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com)
2. Pilih **Settings** → **Access Keys**
3. Salin **Server Key** (format: `SB-Mid-server-xxxxxxxxxxxxx`)

#### Step 2: Set di Supabase

**Via Dashboard** (Recommended):

1. Buka [Supabase Dashboard - Edge Functions](https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions)
2. Klik **"Manage secrets"**
3. Klik **"Add new secret"**
4. Isi:
   ```
   Name: MIDTRANS_SERVER_KEY
   Value: SB-Mid-server-xxxxxxxxxxxxx
   ```
5. Klik **Save**

**Via CLI** (Alternative):

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref rtchxgkayaquwzuicuzy

# Set secret
supabase secrets set MIDTRANS_SERVER_KEY="SB-Mid-server-YOUR_KEY"
```

#### Step 3: Deploy Ulang Edge Functions

```bash
supabase functions deploy midtrans_charge
supabase functions deploy midtrans_webhook
```

Atau via Dashboard:
- Buka Edge Functions → midtrans_charge → **Restart**

#### Step 4: Test Lagi

1. Jalankan app: `flutter run --dart-define-from-file=.env`
2. Checkout parkir
3. Pilih QRIS/VA
4. Klik Bayar
5. **QR atau VA number harus muncul sekarang** ✅

---

## 🔍 Cara Cek Apakah Sudah Benar

### Test 1: Cek Secret di Supabase

1. Buka [Supabase Edge Functions Settings](https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions)
2. Klik "Manage secrets"
3. **Harus ada** `MIDTRANS_SERVER_KEY` dalam daftar

### Test 2: Cek Edge Function Logs

1. Buka Supabase Dashboard → Edge Functions → midtrans_charge → Logs
2. Jalankan payment dari app
3. Lihat logs:

**✅ Logs Sukses:**
```
Charging Midtrans sandbox: method=QRIS, amount=10000, payment_id=xxx
Midtrans response: {"transaction_id":"xxx","actions":[...]}
QRIS URL: https://api.sandbox.midtrans.com/...
```

**❌ Logs Error (Server Key Belum Di-set):**
```
MIDTRANS_SERVER_KEY is not set in environment secrets
```

### Test 3: Cek di Flutter Console

Setelah klik "Bayar QRIS", harusnya muncul:

**✅ Console Sukses:**
```
🔍 Midtrans Charge Response:
   Status: 200
   Data: {success: true, data: {qris_url: https://...}}
✅ QRIS URL berhasil didapat: https://api.sandbox.midtrans.com/...
```

**❌ Console Error:**
```
🔍 Midtrans Charge Response:
   Status: 500
   Data: {error: Server configuration error: MIDTRANS_SERVER_KEY not set}
❌ Error dari Midtrans: Server configuration error...
```

---

## 🎯 Expected Behavior

### QRIS Payment:
1. User klik "Bayar QRIS"
2. Loading 1-2 detik
3. **QR Code muncul** (besar di tengah)
4. **Link QRIS muncul** di bawah QR (untuk sandbox testing)
5. Countdown 10:00 mulai
6. User scan QR atau klik link untuk simulasi bayar

### VA Payment:
1. User klik "Bayar VA BCA"
2. Loading 1-2 detik
3. **Nomor VA muncul** (contoh: 70012345678901)
4. Total tagihan terlihat
5. Countdown 24:00:00 mulai
6. User bayar via m-banking atau simulasi di Midtrans Dashboard

---

## 🐛 Masalah Lain yang Mungkin Terjadi

### Problem: "User profile belum lengkap"

**Cause**: User auth exists tapi tidak ada di tabel `users`

**Fix**: 
1. Pastikan user sudah complete profile
2. Atau manual insert:
   ```sql
   INSERT INTO public.users (id, email, full_name, role)
   VALUES (
     'user-auth-id',  -- Ambil dari Supabase Auth
     'user@example.com',
     'John Doe',
     'user'
   );
   ```

### Problem: "Tidak ada area parkir aktif"

**Cause**: Belum ada parking lot di database

**Fix**: Daftar operator dan approve dari admin dulu

### Problem: Payment stuck di loading

**Cause**: Edge function timeout atau error

**Fix**: 
1. Cek logs di Supabase
2. Cek internet connection
3. Cek Server Key benar (dari Sandbox, bukan Production)

### Problem: QR muncul tapi kosong/placeholder

**Cause**: `qris_url` null dari Midtrans

**Fix**:
1. Cek format request ke Midtrans
2. Cek Server Key valid
3. Cek logs Midtrans response

---

## 📋 Quick Checklist

Sebelum test payment, pastikan:

- [ ] ✅ User sudah lengkapi profil (ada di tabel `users`)
- [ ] ✅ User punya minimal 1 kendaraan (di tabel `vehicles`)
- [ ] ✅ Ada parking lot aktif (di tabel `parking_lots`)
- [ ] ✅ `MIDTRANS_SERVER_KEY` sudah di-set di Supabase
- [ ] ✅ Edge functions sudah deployed
- [ ] ✅ Internet connection stable
- [ ] ✅ Supabase project tidak sleep/paused

---

## 📞 Butuh Bantuan Lebih Lanjut?

Jika setelah ikuti semua step di atas masih error:

1. **Jalankan app dengan verbose logging**:
   ```bash
   flutter run --dart-define-from-file=.env --verbose
   ```

2. **Screenshot**:
   - Error di Flutter console
   - Logs di Supabase Edge Functions
   - Response dari edge function

3. **Cek file**:
   - [MIDTRANS_SETUP.md](./MIDTRANS_SETUP.md) - Setup lengkap
   - [check_midtrans_config.md](./check_midtrans_config.md) - Debug checklist

4. **Test manual**:
   ```bash
   # Test edge function langsung
   curl -X POST \
     https://rtchxgkayaquwzuicuzy.supabase.co/functions/v1/midtrans_charge \
     -H "Authorization: Bearer YOUR_ANON_KEY" \
     -H "Content-Type: application/json" \
     -d '{"payment_id":"test-123","amount":10000,"method":"QRIS"}'
   ```

---

## 🔗 Quick Links

- [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com)
- [Supabase Edge Functions Settings](https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions)
- [Midtrans API Docs](https://docs.midtrans.com)
- [Setup Helper Script](./setup_midtrans.bat) - Jalankan untuk panduan step-by-step

---

**Last Updated**: 2026-07-10  
**Status**: ✅ Fixed  
**Changes Made**: 
- Fixed database foreign key check in payment_cubit.dart
- Enhanced error handling and logging
- Added configuration documentation
