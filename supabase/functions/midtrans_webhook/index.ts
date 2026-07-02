import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"
import { createHash } from "https://deno.land/std@0.177.0/hash/mod.ts";

const MIDTRANS_SERVER_KEY = Deno.env.get('MIDTRANS_SERVER_KEY') ?? ''

serve(async (req: Request) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Midtrans webhook sends POST with JSON payload
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 })
    }

    const payload = await req.json()
    console.log('Webhook payload:', payload)

    const {
      order_id,
      status_code,
      gross_amount,
      signature_key,
      transaction_status
    } = payload

    // Verify signature
    const hash = createHash("sha512");
    hash.update(`${order_id}${status_code}${gross_amount}${MIDTRANS_SERVER_KEY}`);
    const expectedSignature = hash.toString();

    if (expectedSignature !== signature_key) {
      console.error('Invalid signature')
      return new Response('Invalid signature', { status: 403 })
    }

    // Determine the new status
    let newStatus = 'PENDING'
    if (transaction_status === 'settlement' || transaction_status === 'capture') {
      newStatus = 'PAID'
    } else if (transaction_status === 'cancel' || transaction_status === 'deny' || transaction_status === 'expire') {
      newStatus = 'FAILED'
    } else if (transaction_status === 'pending') {
      newStatus = 'PENDING'
    }

    // Update payment in database
    const { error: dbError } = await supabaseClient
      .from('payments')
      .update({ status: newStatus })
      .eq('id', order_id)

    if (dbError) {
      throw dbError
    }

    return new Response('OK', { status: 200 })

  } catch (error) {
    console.error(error)
    return new Response(`Error processing webhook: ${error.message}`, { status: 500 })
  }
})
