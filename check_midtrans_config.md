# 🔍 Quick Check: Midtrans Configuration

Gunakan checklist ini untuk memastikan semua konfigurasi Midtrans sudah benar.

## ✅ Checklist Cepat

### 1. Cek Server Key di Midtrans Dashboard
- [ ] Login ke [https://dashboard.sandbox.midtrans.com](https://dashboard.sandbox.midtrans.com)
- [ ] Masuk ke **Settings → Access Keys**
- [ ] Salin **Server Key** (format: `SB-Mid-server-xxxxx`)

### 2. Cek Environment Variable di Supabase
- [ ] Login ke [Supabase Dashboard](https://supabase.com/dashboard)
- [ ] Pilih project: `rtchxgkayaquwzuicuzy`
- [ ] Buka **Settings → Edge Functions**
- [ ] Klik **Manage secrets**
- [ ] Pastikan ada `MIDTRANS_SERVER_KEY` dengan value yang benar

### 3. Cek Edge Function Status
- [ ] Buka **Edge Functions** di Supabase Dashboard
- [ ] Pastikan `midtrans_charge` sudah deployed (ada icon hijau ✓)
- [ ] Pastikan `midtrans_webhook` sudah deployed

### 4. Test Edge Function Secara Manual

Gunakan curl atau Postman untuk test:

```bash
curl -X POST \
  https://rtchxgkayaquwzuicuzy.supabase.co/functions/v1/midtrans_charge \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "payment_id": "test-123",
    "amount": 10000,
    "method": "QRIS"
  }'
```

**Expected Response** (jika berhasil):
```json
{
  "success": true,
  "data": {
    "midtrans_transaction_id": "xxxxx",
    "qris_url": "https://api.sandbox.midtrans.com/v2/qris/xxxxx/qr-code"
  }
}
```

**Error Response** (jika MIDTRANS_SERVER_KEY belum di-set):
```json
{
  "error": "Server configuration error: MIDTRANS_SERVER_KEY not set"
}
```

### 5. Cek Logs Edge Function

Di Supabase Dashboard:
1. Klik **Edge Functions** → **midtrans_charge**
2. Klik tab **Logs**
3. Filter log terakhir saat Anda test payment dari app

**Log Normal** (sukses):
```
Charging Midtrans sandbox: method=QRIS, amount=10000, payment_id=xxxxx
Midtrans response: {"transaction_id":"xxxxx","actions":[...]}
QRIS URL: https://api.sandbox.midtrans.com/...
```

**Log Error** (MIDTRANS_SERVER_KEY tidak ada):
```
MIDTRANS_SERVER_KEY is not set in environment secrets
```

---

## 🐛 Debug Flutter App

### Tambahkan Debug Print

Edit file `payment_cubit.dart`, tambahkan print statement:

```dart
// Setelah invoke edge function (baris ~112)
final res = await supabase.functions.invoke(
  'midtrans_charge',
  body: {
    'payment_id': paymentId,
    'amount': amount.toInt(),
    'method': 'QRIS',
  },
);

// Tambahkan print ini:
print('🔍 Edge function response status: ${res.status}');
print('🔍 Edge function response data: ${res.data}');

if (res.status == 200 && res.data != null && res.data['data'] != null) {
  qrisUrl = res.data['data']['qris_url'] ?? '';
  print('✅ QRIS URL berhasil: $qrisUrl');
} else {
  print('❌ Error dari edge function: ${res.data}');
}
```

### Run Flutter dengan Debug Mode

```bash
flutter run --dart-define-from-file=.env
```

Lalu lihat output console saat klik "Bayar QRIS".

---

## 🎯 Expected vs Actual Behavior

| Langkah | Expected | Jika Error |
|---------|----------|------------|
| User klik "Bayar QRIS" | Loading muncul | Sama |
| Call edge function | Status 200 | Status 500/502 atau stuck loading |
| Get QRIS URL from Midtrans | URL valid | `qris_url: null` atau error response |
| Display QR | QR muncul + link | QR tidak muncul, masih loading |
| Countdown timer | 10:00 countdown | Timer jalan tapi QR kosong |

---

## 💡 Quick Fix Jika QRIS Tidak Muncul

### Fix 1: Set MIDTRANS_SERVER_KEY

**Via Supabase Dashboard**:
1. Settings → Edge Functions → Manage secrets
2. Add: `MIDTRANS_SERVER_KEY` = `SB-Mid-server-YOUR_KEY`
3. Save
4. Redeploy function: `supabase functions deploy midtrans_charge`

### Fix 2: Restart Edge Function

Setelah set secret, **restart edge function**:
- Di Supabase Dashboard → Edge Functions → midtrans_charge
- Klik **Restart**

Atau via CLI:
```bash
supabase functions deploy midtrans_charge --no-verify-jwt
```

### Fix 3: Test dengan Hardcoded Key (TEMPORARY)

**HANYA UNTUK TESTING**, edit `midtrans_charge/index.ts`:

```typescript
// BEFORE:
const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''

// AFTER (TEMPORARY):
const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? 'SB-Mid-server-YOUR_KEY_HERE'
```

Deploy ulang:
```bash
supabase functions deploy midtrans_charge
```

⚠️ **INGAT**: Setelah berhasil, hapus hardcoded key dan gunakan environment variable!

---

## 📞 Still Not Working?

Jika setelah semua step di atas masih error:

1. **Screenshot**:
   - Error di Flutter console
   - Logs di Supabase Edge Functions
   - Response dari edge function

2. **Check**:
   - Apakah Server Key benar (dari Sandbox, bukan Production)
   - Format Server Key: `SB-Mid-server-xxxxx` (harus ada `SB-`)
   - Internet connection stable

3. **Alternative Test**:
   Test langsung ke Midtrans API tanpa Supabase:
   
   ```bash
   curl -X POST https://api.sandbox.midtrans.com/v2/charge \
     -H "Content-Type: application/json" \
     -H "Authorization: Basic $(echo -n 'SB-Mid-server-YOUR_KEY:' | base64)" \
     -d '{
       "payment_type": "qris",
       "transaction_details": {
         "order_id": "test-001",
         "gross_amount": 10000
       },
       "qris": {
         "acquirer": "gopay"
       }
     }'
   ```

   Jika ini berhasil return QR URL, berarti Midtrans API works → problem ada di Edge Function config.

---

**Quick Links**:
- [Midtrans Server Key](https://dashboard.sandbox.midtrans.com/settings/config_info)
- [Supabase Edge Function Secrets](https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions)
- [Full Setup Guide](./MIDTRANS_SETUP.md)
