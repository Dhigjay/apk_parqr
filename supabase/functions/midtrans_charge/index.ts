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

  // Guard: server key must be configured
  if (!MIDTRANS_SERVER_KEY) {
    console.error('MIDTRANS_SERVER_KEY is not set')
    return new Response(
      JSON.stringify({ error: 'Server configuration error: MIDTRANS_SERVER_KEY not set' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { payment_id, amount, method, bank } = await req.json()

    if (!payment_id || !amount || !method) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: payment_id, amount, method' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Build Midtrans charge payload
    // method from Flutter: 'QRIS' or 'VA'
    const midtransPayload: Record<string, unknown> = {
      transaction_details: {
        order_id: payment_id,
        gross_amount: Math.round(amount), // Midtrans requires integer (no decimals for IDR)
      },
    }

    const upperMethod = method.toUpperCase()

    if (upperMethod === 'QRIS') {
      midtransPayload.payment_type = 'qris'
      midtransPayload.qris = { acquirer: 'gopay' }
    } else if (upperMethod === 'VA') {
      if (!bank) {
        return new Response(
          JSON.stringify({ error: 'Missing required field: bank (e.g. bca, bni, bri)' }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
      }
      midtransPayload.payment_type = 'bank_transfer'
      midtransPayload.bank_transfer = { bank: bank.toLowerCase() }
    } else {
      return new Response(
        JSON.stringify({ error: `Unsupported payment method: ${method}. Use 'QRIS' or 'VA'` }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Call Midtrans Sandbox API
    console.log(`Charging Midtrans sandbox: method=${method}, amount=${amount}, payment_id=${payment_id}`)
    const base64Key = btoa(`${MIDTRANS_SERVER_KEY}:`)
    const midtransRes = await fetch(MIDTRANS_API_URL, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Basic ${base64Key}`,
      },
      body: JSON.stringify(midtransPayload),
    })

    const midtransData = await midtransRes.json()
    console.log('Midtrans response:', JSON.stringify(midtransData))

    if (midtransRes.status !== 200 && midtransRes.status !== 201) {
      console.error('Midtrans API error:', midtransData)
      return new Response(
        JSON.stringify({ error: 'Midtrans API error', details: midtransData }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 502 }
      )
    }

    // Extract relevant data from Midtrans response
    const updateData: Record<string, unknown> = {
      midtrans_transaction_id: midtransData.transaction_id ?? null,
    }

    if (upperMethod === 'QRIS') {
      // Midtrans returns QR URL inside actions array
      const qrAction = (midtransData.actions ?? []).find(
        (a: { name: string; url: string }) => a.name === 'generate-qr-code'
      )
      updateData.qris_url = qrAction?.url ?? null
      console.log(`QRIS URL: ${updateData.qris_url}`)
    } else if (upperMethod === 'VA') {
      // Standard banks (bca, bni, bri) return va_numbers array
      if (midtransData.va_numbers && midtransData.va_numbers.length > 0) {
        updateData.va_number = midtransData.va_numbers[0].va_number
        updateData.bank = midtransData.va_numbers[0].bank
      } else if (midtransData.permata_va_number) {
        // Permata bank returns va_number differently
        updateData.va_number = midtransData.permata_va_number
        updateData.bank = 'permata'
      }
      console.log(`VA Number: ${updateData.va_number} (${updateData.bank})`)
    }

    // Save Midtrans data back to payments table
    const { error: dbError } = await supabaseClient
      .from('payments')
      .update(updateData)
      .eq('id', payment_id)

    if (dbError) {
      console.error('DB update error:', dbError)
      throw new Error(`DB update failed: ${dbError.message}`)
    }

    return new Response(
      JSON.stringify({ success: true, data: updateData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Unhandled error in midtrans_charge:', error)
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
