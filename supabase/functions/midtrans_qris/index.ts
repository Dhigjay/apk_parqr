import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''
// Use sandbox URL for development, change to production URL later
const MIDTRANS_API_URL = 'https://api.sandbox.midtrans.com/v2/charge'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get the request payload
    const { payment_id, amount } = await req.json()

    if (!payment_id || !amount) {
      return new Response(
        JSON.stringify({ error: 'Missing payment_id or amount' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Prepare Midtrans payload for QRIS
    const payload = {
      payment_type: 'qris',
      transaction_details: {
        order_id: payment_id,
        gross_amount: amount
      },
      qris: {
        acquirer: 'gopay' // Midtrans uses gopay as acquirer for QRIS in sandbox usually
      }
    }

    // Call Midtrans API
    const base64Key = btoa(`${MIDTRANS_SERVER_KEY}:`)
    const midtransRes = await fetch(MIDTRANS_API_URL, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Basic ${base64Key}`
      },
      body: JSON.stringify(payload)
    })

    const midtransData = await midtransRes.json()

    if (midtransRes.status !== 200 && midtransRes.status !== 201) {
      console.error('Midtrans Error:', midtransData)
      return new Response(
        JSON.stringify({ error: 'Failed to charge Midtrans', details: midtransData }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      )
    }

    // Extract QRIS URL (actions array usually contains the generate-qr URL)
    let qrisUrl = ''
    if (midtransData.actions && midtransData.actions.length > 0) {
      const action = midtransData.actions.find((a: any) => a.name === 'generate-qr-code')
      if (action) qrisUrl = action.url
    }

    // Save to payments table
    const { error: dbError } = await supabaseClient
      .from('payments')
      .update({
        midtrans_transaction_id: midtransData.transaction_id,
        qris_url: qrisUrl
      })
      .eq('id', payment_id)

    if (dbError) {
      throw dbError
    }

    return new Response(
      JSON.stringify({ success: true, qris_url: qrisUrl }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error(error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
