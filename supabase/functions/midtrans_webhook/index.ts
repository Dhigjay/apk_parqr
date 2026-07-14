import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-callback-key',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  if (!MIDTRANS_SERVER_KEY) {
    console.error('MIDTRANS_SERVER_KEY is not set')
    return new Response('Server configuration error', { status: 500, headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const payload = await req.json()
    console.log('Midtrans webhook received:', JSON.stringify(payload))

    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status,
    } = payload

    if (!order_id || !status_code || !gross_amount || !signature_key) {
      console.error('Missing required fields')
      return new Response('Bad Request', { status: 400, headers: corsHeaders })
    }

    // Verifikasi signature Midtrans
    const rawString = `${order_id}${status_code}${gross_amount}${MIDTRANS_SERVER_KEY}`
    const encoder = new TextEncoder()
    const hashBuffer = await crypto.subtle.digest('SHA-512', encoder.encode(rawString))
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const expectedSignature = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

    if (expectedSignature !== signature_key) {
      console.warn(`Signature mismatch for order ${order_id}`)
      // Izinkan test dari Midtrans Dashboard (order_id tidak valid UUID)
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
      if (!uuidRegex.test(order_id)) {
        return new Response('OK (mock test)', { status: 200, headers: corsHeaders })
      }
      return new Response('Forbidden: invalid signature', { status: 403, headers: corsHeaders })
    }

    // Map status Midtrans → status DB
    let newPaymentStatus = 'pending'
    if (transaction_status === 'settlement' || transaction_status === 'capture') {
      newPaymentStatus = 'paid'
    } else if (['cancel', 'deny', 'expire'].includes(transaction_status)) {
      newPaymentStatus = 'failed'
    }

    // ✅ Query payment berdasarkan qris_reference (= order_id dari Midtrans)
    // bukan berdasarkan id, karena order_id format PARQR-xxx bukan UUID payments.id
    const { data: paymentData, error: findError } = await supabaseClient
      .from('payments')
      .select('id, session_id')
      .eq('qris_reference', order_id)
      .maybeSingle()

    if (findError) {
      console.error('DB error finding payment:', findError)
      throw new Error(`Failed to find payment: ${findError.message}`)
    }

    if (!paymentData) {
      console.warn(`Payment with qris_reference ${order_id} not found — ignoring`)
      return new Response('OK', { status: 200, headers: corsHeaders })
    }

    // Update status payment
    const updatePayload: Record<string, unknown> = { status: newPaymentStatus }
    if (newPaymentStatus === 'paid') {
      updatePayload.paid_at = new Date().toISOString()
    }

    const { error: updateError } = await supabaseClient
      .from('payments')
      .update(updatePayload)
      .eq('id', paymentData.id)

    if (updateError) {
      console.error('DB error updating payment:', updateError)
      throw new Error(`Failed to update payment: ${updateError.message}`)
    }

    // Update status parking_session jika payment lunas
    if (newPaymentStatus === 'paid' && paymentData.session_id) {
      const { error: sessionError } = await supabaseClient
        .from('parking_sessions')
        .update({ status: 'completed' })
        .eq('id', paymentData.session_id)

      if (sessionError) {
        console.error('Failed to update parking_session:', sessionError)
      } else {
        console.log(`parking_session ${paymentData.session_id} → completed`)
      }
    }

    console.log(`✅ Payment ${paymentData.id} (order: ${order_id}) → ${newPaymentStatus}`)
    return new Response('OK', { status: 200, headers: corsHeaders })

  } catch (error) {
    console.error('Unhandled webhook error:', error)
    return new Response(
      `Webhook error: ${error instanceof Error ? error.message : String(error)}`,
      { status: 500, headers: corsHeaders }
    )
  }
})