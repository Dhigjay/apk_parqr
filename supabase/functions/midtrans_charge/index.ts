import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''
const MIDTRANS_API_URL = 'https://api.sandbox.midtrans.com/v2/charge'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { payment_id, amount, method, bank } = await req.json()

    if (!payment_id || !amount || !method) {
      return new Response(
        JSON.stringify({ error: 'Missing payment_id, amount, or method' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    let payload: any = {
      transaction_details: {
        order_id: payment_id,
        gross_amount: amount
      }
    }

    if (method === 'QRIS') {
      payload.payment_type = 'qris'
      payload.qris = { acquirer: 'gopay' }
    } else if (method === 'VA') {
      payload.payment_type = 'bank_transfer'
      payload.bank_transfer = { bank: bank.toLowerCase() } // bca, bni, bri
    } else {
      throw new Error('Unsupported payment method')
    }

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

    let updateData: any = {
      midtrans_transaction_id: midtransData.transaction_id,
    }

    if (method === 'QRIS') {
      if (midtransData.actions && midtransData.actions.length > 0) {
        const action = midtransData.actions.find((a: any) => a.name === 'generate-qr-code')
        if (action) updateData.qris_url = action.url
      }
    } else if (method === 'VA') {
      if (midtransData.va_numbers && midtransData.va_numbers.length > 0) {
        updateData.va_number = midtransData.va_numbers[0].va_number
        updateData.bank = midtransData.va_numbers[0].bank
      }
      // For Permata, va_number is at the root sometimes, but midtrans docs says it's in permata_va_number. Let's handle standard bank_transfer (bca, bni, bri).
    }

    const { error: dbError } = await supabaseClient
      .from('payments')
      .update(updateData)
      .eq('id', payment_id)

    if (dbError) {
      throw dbError
    }

    return new Response(
      JSON.stringify({ success: true, data: updateData }),
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
