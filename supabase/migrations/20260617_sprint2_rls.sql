-- Enable RLS for parking_lots
ALTER TABLE parking_lots ENABLE ROW LEVEL SECURITY;

-- Allow anyone (authenticated) to view parking lots
CREATE POLICY "Anyone can view parking lots" 
ON parking_lots FOR SELECT 
TO authenticated 
USING (true);

-- Allow operators to insert their own parking lots
CREATE POLICY "Operators can insert parking lots" 
ON parking_lots FOR INSERT 
TO authenticated 
WITH CHECK (operator_id = auth.uid());

-- Allow operators to update their own parking lots
CREATE POLICY "Operators can update their own parking lots" 
ON parking_lots FOR UPDATE 
TO authenticated 
USING (operator_id = auth.uid()) 
WITH CHECK (operator_id = auth.uid());

-- Allow operators to delete their own parking lots
CREATE POLICY "Operators can delete their own parking lots" 
ON parking_lots FOR DELETE 
TO authenticated 
USING (operator_id = auth.uid());


-- Enable RLS for parking_sessions
ALTER TABLE parking_sessions ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own sessions
-- Allow operators to view sessions in their parking lots
CREATE POLICY "Users can view own sessions, Operators can view lot sessions" 
ON parking_sessions FOR SELECT 
TO authenticated 
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM parking_lots 
    WHERE parking_lots.id = parking_sessions.parking_lot_id 
    AND parking_lots.operator_id = auth.uid()
  )
);

-- Allow users to insert their own sessions (booking)
CREATE POLICY "Users can insert own sessions" 
ON parking_sessions FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());

-- Allow users to update their own sessions (e.g. checkout intent)
-- Allow operators to update sessions in their lots (e.g. verify cash payment)
CREATE POLICY "Users and Operators can update sessions" 
ON parking_sessions FOR UPDATE 
TO authenticated 
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM parking_lots 
    WHERE parking_lots.id = parking_sessions.parking_lot_id 
    AND parking_lots.operator_id = auth.uid()
  )
)
WITH CHECK (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM parking_lots 
    WHERE parking_lots.id = parking_sessions.parking_lot_id 
    AND parking_lots.operator_id = auth.uid()
  )
);
