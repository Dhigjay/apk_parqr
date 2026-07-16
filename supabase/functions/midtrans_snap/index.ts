import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { payment_id, amount } = await req.json()

    if (!payment_id || !amount) {
      return new Response(
        JSON.stringify({ error: 'payment_id dan amount wajib diisi.' }),
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
    console.log(`Snap order_id: ${orderId} (${orderId.length} chars)`)

    const snapBody = {
      transaction_details: {
        order_id: orderId,
        gross_amount: Math.round(amount),
      },
      credit_card: {
        secure: true,
      },
    }

    const snapRes = await fetch(
      'https://app.sandbox.midtrans.com/snap/v1/transactions',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
        body: JSON.stringify(snapBody),
      }
    )

    const snapData = await snapRes.json()
    console.log('Midtrans Snap response:', JSON.stringify(snapData))

    if (!snapRes.ok || !snapData.token) {
      return new Response(
        JSON.stringify({
          error: snapData.error_messages?.[0] ?? snapData.status_message ?? 'Gagal membuat Snap token',
          detail: snapData,
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        data: {
          snap_token: snapData.token,
          snap_url: snapData.redirect_url,
          order_id: orderId,
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