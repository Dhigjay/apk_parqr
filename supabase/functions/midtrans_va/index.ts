import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Bank yang didukung Midtrans sandbox untuk Virtual Account
const SUPPORTED_BANKS = ['bca', 'bni', 'bri', 'mandiri', 'permata']

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { payment_id, amount, bank } = await req.json()

    if (!payment_id || !amount || !bank) {
      return new Response(
        JSON.stringify({ error: 'payment_id, amount, dan bank wajib diisi.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const bankLower = bank.toLowerCase()
    if (!SUPPORTED_BANKS.includes(bankLower)) {
      return new Response(
        JSON.stringify({ error: `Bank tidak didukung. Pilih: ${SUPPORTED_BANKS.join(', ')}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')
    if (!serverKey) {
      return new Response(
        JSON.stringify({ error: 'MIDTRANS_SERVER_KEY tidak ditemukan.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const authHeader = 'Basic ' + btoa(serverKey + ':')

    // order_id max 50 karakter
    const shortId = payment_id.replace(/-/g, '').substring(0, 16)
    const orderId = `PARQR-${shortId}-${Date.now()}`
    console.log(`VA order_id: ${orderId} (${orderId.length} chars), bank: ${bankLower}`)

    // Mandiri pakai echannel, selain itu pakai bank_transfer
    let chargeBody: Record<string, unknown>

    if (bankLower === 'mandiri') {
      chargeBody = {
        payment_type: 'echannel',
        transaction_details: {
          order_id: orderId,
          gross_amount: Math.round(amount),
        },
        echannel: {
          bill_info1: 'ParQr Parking',
          bill_info2: 'Pembayaran Parkir',
        },
      }
    } else {
      chargeBody = {
        payment_type: 'bank_transfer',
        transaction_details: {
          order_id: orderId,
          gross_amount: Math.round(amount),
        },
        bank_transfer: {
          bank: bankLower,
        },
      }
    }

    const chargeRes = await fetch(
      'https://api.sandbox.midtrans.com/v2/charge',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
        body: JSON.stringify(chargeBody),
      }
    )

    const chargeData = await chargeRes.json()
    console.log('Midtrans VA response:', JSON.stringify(chargeData))

    if (!chargeRes.ok || chargeData.status_code === '500') {
      return new Response(
        JSON.stringify({
          error: chargeData.status_message ?? 'Gagal membuat Virtual Account',
          detail: chargeData,
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Ambil nomor VA dari response (struktur berbeda per bank)
    let vaNumber: string | null = null

    if (bankLower === 'mandiri') {
      vaNumber = chargeData.bill_key ?? null
    } else if (bankLower === 'permata') {
      vaNumber = chargeData.permata_va_number ?? null
    } else {
      // bca, bni, bri
      vaNumber = chargeData.va_numbers?.[0]?.va_number ?? null
    }

    return new Response(
      JSON.stringify({
        data: {
          va_number: vaNumber,
          bank: bankLower,
          order_id: orderId,
          transaction_id: chargeData.transaction_id,
          status: chargeData.transaction_status,
        },
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('Edge function error:', err)
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})