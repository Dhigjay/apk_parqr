import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Missing Authorization header')
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // Check if user is admin
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) throw new Error('Unauthorized')

    const { data: profile, error: profileError } = await supabaseClient
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single()
    
    if (profileError || profile?.role !== 'admin') {
      throw new Error('Forbidden: Only admin can approve operators')
    }

    const { registration_id } = await req.json()

    // Now use service role to bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get registration details
    const { data: registration, error: regError } = await supabaseAdmin
      .from('operator_registrations')
      .select('*')
      .eq('id', registration_id)
      .single()

    if (regError || !registration) throw new Error('Registration not found')
    if (registration.status !== 'pending') throw new Error('Registration is not pending')

    // Create a new user for the operator
    const operatorEmail = `operator_${registration_id.substring(0, 8)}@parqr.app`
    const tempPassword = Math.random().toString(36).slice(-10) + 'A1!'

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: operatorEmail,
      password: tempPassword,
      email_confirm: true,
      user_metadata: {
        full_name: `${registration.business_name} Operator`,
        role: 'operator'
      }
    })

    if (authError) throw authError

    const operatorId = authData.user.id

    // Update the newly created user's profile to operator
    // The users table triggers should have created the row already, so we just update it
    await supabaseAdmin
      .from('users')
      .update({ role: 'operator', full_name: `${registration.business_name} Operator` })
      .eq('id', operatorId)

    // Create parking lot
    const { error: lotError } = await supabaseAdmin
      .from('parking_lots')
      .insert({
        operator_id: operatorId,
        registration_id: registration.id,
        name: registration.business_name,
        address: registration.address,
        latitude: registration.latitude,
        longitude: registration.longitude,
        floors: registration.floors,
        total_capacity: registration.total_capacity,
        price_per_hour: registration.price_per_hour,
        photo_url: registration.photo_url,
        is_active: true
      })

    if (lotError) {
      // rollback user
      await supabaseAdmin.auth.admin.deleteUser(operatorId)
      throw lotError
    }

    // Update registration status
    const { error: updateRegError } = await supabaseAdmin
      .from('operator_registrations')
      .update({ 
        status: 'approved',
        reviewed_by: user.id,
        reviewed_at: new Date().toISOString()
      })
      .eq('id', registration.id)

    if (updateRegError) throw updateRegError

    return new Response(
      JSON.stringify({
        message: 'Operator approved successfully',
        email: operatorEmail,
        password: tempPassword
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
