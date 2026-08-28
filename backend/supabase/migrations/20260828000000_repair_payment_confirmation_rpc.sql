-- Recreate the secured payment confirmation RPC in a new migration.
-- Production databases may already have recorded the original hardening
-- migration while still retaining an older five-argument function signature.

DROP FUNCTION IF EXISTS public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC);
DROP FUNCTION IF EXISTS public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC, UUID);

CREATE FUNCTION public.confirm_order_payment(
  p_order_id UUID,
  p_razorpay_payment_id TEXT,
  p_razorpay_order_id TEXT,
  p_razorpay_signature TEXT,
  p_amount NUMERIC,
  p_user_id UUID DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_order public.orders%ROWTYPE;
  v_payment public.payments%ROWTYPE;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized: only service_role can confirm payments';
  END IF;

  IF p_razorpay_payment_id IS NULL OR btrim(p_razorpay_payment_id) = '' OR
     p_razorpay_order_id IS NULL OR btrim(p_razorpay_order_id) = '' OR
     p_razorpay_signature IS NULL OR btrim(p_razorpay_signature) = '' OR
     p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'Invalid payment confirmation parameters';
  END IF;

  SELECT * INTO v_order
  FROM public.orders
  WHERE id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  SELECT * INTO v_payment
  FROM public.payments
  WHERE order_id = p_order_id
    AND razorpay_order_id = p_razorpay_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payment does not belong to the supplied order';
  END IF;

  IF p_user_id IS NOT NULL AND v_order.user_id IS DISTINCT FROM p_user_id THEN
    RAISE EXCEPTION 'Order does not belong to the supplied user';
  END IF;

  IF v_order.total_amount IS DISTINCT FROM p_amount OR
     v_payment.amount IS DISTINCT FROM p_amount THEN
    RAISE EXCEPTION 'Payment amount mismatch';
  END IF;

  IF v_order.status = 'confirmed' AND v_order.payment_status = 'paid' THEN
    IF v_payment.status = 'captured' AND
       v_payment.razorpay_payment_id = p_razorpay_payment_id THEN
      RETURN;
    END IF;
    RAISE EXCEPTION 'Order is already paid with a different payment';
  END IF;

  IF v_order.status NOT IN ('pending_payment', 'pending') OR
     v_order.payment_status NOT IN ('unpaid', 'processing') THEN
    RAISE EXCEPTION 'Order is not in a payable state';
  END IF;

  UPDATE public.payments
  SET razorpay_payment_id = p_razorpay_payment_id,
      razorpay_signature = p_razorpay_signature,
      status = 'captured',
      updated_at = NOW()
  WHERE id = v_payment.id;

  UPDATE public.orders
  SET status = 'confirmed',
      payment_status = 'paid',
      updated_at = NOW()
  WHERE id = p_order_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_order_payment(UUID, TEXT, TEXT, TEXT, NUMERIC, UUID)
  TO service_role;

-- Ensure PostgREST immediately sees the repaired signature.
NOTIFY pgrst, 'reload schema';
