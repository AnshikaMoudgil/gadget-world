-- =========================================================================
-- SECTION 7: Auto-Clear Cart Function & Trigger on Order Confirmation
-- =========================================================================

-- RPC function to clear user's cart manually if needed
CREATE OR REPLACE FUNCTION public.clear_user_cart(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.cart_items
  WHERE cart_id IN (
    SELECT id FROM public.carts WHERE user_id = p_user_id
  );
END;
$$;

-- Automatic trigger to clear cart when an order is confirmed
CREATE OR REPLACE FUNCTION public.handle_order_confirmed_clear_cart()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.status = 'confirmed') OR
     (TG_OP = 'UPDATE' AND NEW.status = 'confirmed' AND OLD.status IN ('pending_payment', 'pending')) THEN
    PERFORM public.clear_user_cart(NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_confirmed_clear_cart ON public.orders;

CREATE TRIGGER on_order_confirmed_clear_cart
  AFTER INSERT OR UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_confirmed_clear_cart();
