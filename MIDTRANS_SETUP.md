# 🔧 Panduan Setup Midtrans Sandbox untuk ParQr

## 📋 Checklist Setup

- [ ] 1. Daftar akun Midtrans Sandbox
- [ ] 2. Dapatkan Server Key
- [ ] 3. Set environment variable di Supabase
- [ ] 4. Deploy edge functions
- [ ] 5. Test payment flow

---

## 1️⃣ Daftar Midtrans Sandbox

1. Buka [https://dashboard.sandbox.midtrans.com/register](https://dashboard.sandbox.midtrans.com/register)
2. Isi form registrasi:
   - Email
   - Password
   - Nama bisnis (contoh: "ParQr")
3. Verifikasi email
4. Login ke dashboard

---

## 2️⃣ Dapatkan Server Key

1. Login ke [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com)
2. Pilih **Settings** → **Access Keys**
3. Salin **Server Key** (format: `SB-Mid-server-xxxxxxxxxxxxx`)
   
   ⚠️ **PENTING**: Jangan share Server Key ini ke public!

---

## 3️⃣ Set Environment Variable di Supabase

### Via Supabase Dashboard (Recommended):

1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda: `rtchxgkayaquwzuicuzy`
3. Klik **Settings** (icon ⚙️ di sidebar kiri bawah)
4. Pilih **Edge Functions** → **Manage secrets**
5. Tambahkan secret baru:
   ```
   Key: MIDTRANS_SERVER_KEY
   Value: SB-Mid-server-xxxxxxxxxxxxx (paste Server Key Anda)
   ```
6. Klik **Save**

### Via Supabase CLI (Alternative):

```bash
# Install Supabase CLI jika belum
npm install -g supabase

# Login ke Supabase
supabase login

# Link project
supabase link --project-ref rtchxgkayaquwzuicuzy

# Set secret
supabase secrets set MIDTRANS_SERVER_KEY="SB-Mid-server-xxxxxxxxxxxxx"
```

---

## 4️⃣ Deploy Edge Functions

Setelah set secret, deploy ulang edge functions agar bisa menggunakan MIDTRANS_SERVER_KEY:

```bash
# Deploy semua functions
supabase functions deploy midtrans_charge
supabase functions deploy midtrans_webhook

# Atau deploy semua sekaligus
supabase functions deploy
```

---

## 5️⃣ Test Payment Flow

### Test QRIS:

1. Jalankan aplikasi Flutter
2. Masuk ke flow checkout parkir
3. Pilih metode pembayaran **QRIS**
4. Klik **Bayar Sekarang**
5. **QR Code dan Link QRIS harus muncul**
6. Untuk simulasi pembayaran di Sandbox:
   - Salin link QRIS yang muncul
   - Buka link di browser
   - Akan muncul simulator pembayaran Midtrans
   - Klik tombol **Pay** untuk simulasi pembayaran sukses

### Test Virtual Account:

1. Pilih metode **Virtual Account BCA/BNI**
2. Klik **Bayar Sekarang**
3. **Nomor VA harus muncul** (contoh: `70012345678901`)
4. Untuk simulasi pembayaran:
   - Buka [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com)
   - Masuk ke **Transactions**
   - Cari transaksi dengan order_id (payment_id dari app)
   - Klik **Actions** → **Change Status** → **Settlement**

---

## 🔍 Troubleshooting

### Problem: QR/VA tidak muncul, masih loading terus

**Kemungkinan penyebab**:

1. ✅ **MIDTRANS_SERVER_KEY belum di-set**
   - Cek di Supabase Dashboard → Settings → Edge Functions → Secrets
   - Pastikan ada `MIDTRANS_SERVER_KEY`

2. ✅ **Edge Function belum di-deploy**
   - Deploy ulang: `supabase functions deploy midtrans_charge`

3. ✅ **Cek logs edge function**
   ```bash
   supabase functions serve midtrans_charge --debug
   ```
   Atau lihat di Supabase Dashboard → Edge Functions → midtrans_charge → Logs

### Problem: Error "Server configuration error: MIDTRANS_SERVER_KEY not set"

**Solusi**: MIDTRANS_SERVER_KEY belum tersedia di edge function. Ikuti langkah #3 di atas.

### Problem: Error "Midtrans API error"

**Cek logs**:
1. Buka Supabase Dashboard → Edge Functions → midtrans_charge → Logs
2. Lihat response dari Midtrans API
3. Common errors:
   - `401 Unauthorized`: Server Key salah
   - `400 Bad Request`: Format payload salah

### Problem: Database error "violates foreign key constraint vehicles_user_id_fkey"

**Solusi**: User profile belum lengkap di database.

1. Pastikan user sudah lengkapi profil via halaman `complete_profile_page`
2. Atau manual insert ke tabel `users`:
   ```sql
   INSERT INTO public.users (id, email, full_name, phone_number, role)
   VALUES (
     'user-id-dari-auth',
     'user@example.com',
     'John Doe',
     '081234567890',
     'user'
   );
   ```

---

## 📝 Testing dengan Data Sandbox

### Test Cards (untuk Credit Card):
```
Card Number: 4811 1111 1111 1114
CVV: 123
Exp: 01/25
```

### Test QRIS:
- Sandbox otomatis generate QR
- Bisa disimulasikan via Midtrans Dashboard

### Test Virtual Account:
- Sandbox otomatis generate nomor VA
- Simulasi pembayaran via Dashboard

---

## 🎯 Expected Behavior

### QRIS Payment Flow:
```
User klik Bayar QRIS 
  → Loading "Membuat QRIS dari Midtrans..."
  → QR Code muncul + Link QRIS di bawahnya
  → User bayar (simulasi)
  → Status otomatis update via webhook
  → Redirect ke Exit QR page
```

### VA Payment Flow:
```
User klik Bayar VA BCA
  → Loading...
  → Nomor VA muncul (contoh: 70012345678901)
  → Total tagihan terlihat
  → User bayar (simulasi via Dashboard)
  → Status update via webhook
  → Redirect ke Exit QR page
```

---

## 🔗 Useful Links

- [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com)
- [Midtrans API Docs](https://docs.midtrans.com)
- [Supabase Dashboard](https://supabase.com/dashboard)
- [Supabase CLI Docs](https://supabase.com/docs/reference/cli)

---

## 📞 Need Help?

Jika masih error setelah mengikuti panduan ini:

1. Screenshot error di aplikasi
2. Cek logs di:
   - Supabase Dashboard → Edge Functions → Logs
   - Flutter Debug Console
3. Share error message lengkap

---

**Last Updated**: 2026-07-10
**Author**: Kiro AI Assistant
