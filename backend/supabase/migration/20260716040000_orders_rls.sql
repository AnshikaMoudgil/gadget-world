-- =========================================================================
-- SECTION 4: Row Level Security (RLS) Policies for Orders & Payments
-- =========================================================================

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Orders
CREATE POLICY "Users read own orders" ON public.orders
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users insert own orders" ON public.orders
  FOR INSERT WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users update own pending orders" ON public.orders
  FOR UPDATE
  USING (
    user_id = auth.uid()
    AND status IN ('pending_payment', 'pending')
    AND NOT public.is_current_user_suspended()
  )
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'cancelled'
    AND NOT public.is_current_user_suspended()
  );

CREATE POLICY "Admins manage all orders" ON public.orders
  FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());

-- Order Items
CREATE POLICY "Users read own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_items.order_id AND o.user_id = auth.uid())
  );

CREATE POLICY "Users insert own order items" ON public.order_items
  FOR INSERT WITH CHECK (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_items.order_id AND o.user_id = auth.uid())
  );

CREATE POLICY "Admins manage all order items" ON public.order_items
  FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());

-- Payments
CREATE POLICY "Users read own payments" ON public.payments
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders o WHERE o.id = payments.order_id AND o.user_id = auth.uid())
  );

CREATE POLICY "Admins manage all payments" ON public.payments
  FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
