import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 })
  }

  try {
    const payload = await req.json()
    // Example: Midtrans webhook payload parsing
    const { order_id, transaction_status, gross_amount, signature_key } = payload
    
    // In a real scenario, you MUST verify the signature_key here to ensure 
    // the request actually comes from the payment gateway!

    if (transaction_status === 'settlement' || transaction_status === 'capture') {
      // Initialize Supabase Client
      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      const supabase = createClient(supabaseUrl, supabaseServiceKey)

      // Fetch payment to check current status (idempotency check)
      const { data: payment, error: fetchError } = await supabase
        .from('payments')
        .select('status')
        .eq('id', order_id)
        .single()

      if (fetchError) throw fetchError

      // Only update if not already paid
      if (payment.status !== 'paid') {
        const { error: updateError } = await supabase
          .from('payments')
          .update({ status: 'paid', paid_at: new Date().toISOString(), updated_at: new Date().toISOString() })
          .eq('id', order_id)

        if (updateError) throw updateError

        // Log the event
        await supabase.rpc('log_audit_event', {
          p_action: 'qris_payment_verified',
          p_entity_type: 'payment',
          p_entity_id: order_id,
          p_metadata: { gross_amount, transaction_status }
        })
      }

      return new Response(JSON.stringify({ message: 'Payment verified successfully' }), { status: 200 })
    }

    return new Response(JSON.stringify({ message: 'Ignored status' }), { status: 200 })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})
