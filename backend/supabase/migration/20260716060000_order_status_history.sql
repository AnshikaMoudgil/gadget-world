-- =========================================================================
-- SECTION 6: Order Status History / Tracking Timeline
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id
  ON public.order_status_history(order_id);

-- Automatic trigger to record order status changes
CREATE OR REPLACE FUNCTION public.handle_order_status_history_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.status <> OLD.status) THEN
    INSERT INTO public.order_status_history (
      order_id,
      status,
      notes,
      created_by
    ) VALUES (
      NEW.id,
      NEW.status,
      CASE
        WHEN NEW.status = 'pending_payment' THEN 'Order placed, awaiting payment confirmation.'
        WHEN NEW.status = 'pending' THEN 'Order received, pending admin confirmation.'
        WHEN NEW.status = 'confirmed' THEN 'Payment received and order confirmed.'
        WHEN NEW.status = 'processing' THEN 'Order is being packed.'
        WHEN NEW.status = 'shipped' THEN 'Order has been dispatched.'
        WHEN NEW.status = 'delivered' THEN 'Order successfully delivered.'
        WHEN NEW.status = 'cancelled' THEN 'Order was cancelled.'
        ELSE 'Order status updated.'
      END,
      auth.uid()
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_status_history_log ON public.orders;

CREATE TRIGGER on_order_status_history_log
  AFTER INSERT OR UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_status_history_log();

-- =========================================================================
-- Row Level Security (RLS)
-- =========================================================================

ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own order status history" ON public.order_status_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_status_history.order_id
        AND o.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins manage all order status history" ON public.order_status_history
  FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
