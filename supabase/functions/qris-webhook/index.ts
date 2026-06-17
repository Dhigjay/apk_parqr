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

      // Update payment status to PAID
      const { data, error } = await supabase
        .from('payments')
        .update({ status: 'PAID', updated_at: new Date().toISOString() })
        .eq('id', order_id)

      if (error) throw error

      return new Response(JSON.stringify({ message: 'Payment verified successfully' }), { status: 200 })
    }

    return new Response(JSON.stringify({ message: 'Ignored status' }), { status: 200 })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})
