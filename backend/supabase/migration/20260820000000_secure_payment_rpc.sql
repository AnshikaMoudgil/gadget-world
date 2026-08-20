-- Revoke public execute rights
REVOKE EXECUTE ON FUNCTION public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC) TO service_role;

-- Recreate the function with added validation
CREATE OR REPLACE FUNCTION public.confirm_order_payment(
  p_order_id UUID,
  p_razorpay_payment_id TEXT,
  p_razorpay_order_id TEXT,
  p_razorpay_signature TEXT,
  p_amount NUMERIC
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_order RECORD;
BEGIN
  -- Validate caller is service_role
  IF auth.role() != 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized: Only service_role can confirm payments directly.';
  END IF;

  -- Fetch and lock the order to prevent race conditions
  SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  -- Validate the order state
  IF v_order.status NOT IN ('pending_payment', 'pending') THEN
    RAISE EXCEPTION 'Order is not in a payable state (current status: %)', v_order.status;
  END IF;

  -- Validate amount against order total (total_amount)
  -- The Dart backend passes amount in subunits (e.g. 15000 for 150.00). 
  IF (v_order.total_amount * 100) != p_amount THEN
    RAISE EXCEPTION 'Payment amount mismatch. Expected %, received %', (v_order.total_amount * 100), p_amount;
  END IF;

  -- 1. Insert payment record safely
  INSERT INTO public.payments (
    order_id,
    provider,
    razorpay_payment_id,
    razorpay_order_id,
    razorpay_signature,
    amount,
    status
  ) VALUES (
    p_order_id,
    'razorpay',
    p_razorpay_payment_id,
    p_razorpay_order_id,
    p_razorpay_signature,
    p_amount,
    'captured'
  ) ON CONFLICT (razorpay_payment_id) DO UPDATE
    SET status = 'captured',
        updated_at = NOW();

  -- 2. Update order status and payment_status atomically
  UPDATE public.orders
  SET status = 'confirmed',
      payment_status = 'paid',
      updated_at = NOW()
  WHERE id = p_order_id;
END;
$$;
