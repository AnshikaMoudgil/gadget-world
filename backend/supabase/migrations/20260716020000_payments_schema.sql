-- =========================================================================
-- SECTION 2: Payments Schema & Atomic Confirmation RPC Function
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
  provider TEXT NOT NULL DEFAULT 'razorpay',
  razorpay_payment_id TEXT UNIQUE,
  razorpay_order_id TEXT,
  razorpay_signature TEXT,
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  currency TEXT NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL DEFAULT 'created'
    CHECK (status IN ('created', 'authorized', 'captured', 'failed', 'refunded')),
  raw_response JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_order_id ON public.payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_razorpay_payment_id ON public.payments(razorpay_payment_id);

CREATE TRIGGER on_payment_updated BEFORE UPDATE ON public.payments
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Atomic order confirmation + payment insert (handles client vs webhook race condition)
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
BEGIN
  -- 1. Insert payment record safely (ON CONFLICT prevents double inserts from concurrent webhooks/client calls)
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
  WHERE id = p_order_id
    AND status IN ('pending_payment', 'pending');
END;
$$;
