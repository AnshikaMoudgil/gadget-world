-- =========================================================================
-- SECTION 3: Automatic Stock Management Triggers (Deduct & Restore)
-- =========================================================================

CREATE OR REPLACE FUNCTION public.handle_order_status_stock_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  item RECORD;
BEGIN
  -- Deduct inventory when order is confirmed (either on insert or when status changes from pending to confirmed)
  IF (TG_OP = 'INSERT' AND NEW.status = 'confirmed') OR
     (TG_OP = 'UPDATE' AND NEW.status = 'confirmed' AND OLD.status IN ('pending_payment', 'pending')) THEN
    FOR item IN SELECT product_id, variant_id, quantity FROM public.order_items WHERE order_id = NEW.id LOOP
      IF item.variant_id IS NOT NULL THEN
        UPDATE public.product_variants
        SET stock_quantity = GREATEST(0, stock_quantity - item.quantity)
        WHERE id = item.variant_id;
      ELSE
        UPDATE public.products
        SET stock_quantity = GREATEST(0, stock_quantity - item.quantity)
        WHERE id = item.product_id;
      END IF;
    END LOOP;
  END IF;

  -- Restore inventory if an order is cancelled after being confirmed or processing
  IF (TG_OP = 'UPDATE' AND NEW.status = 'cancelled' AND OLD.status IN ('confirmed', 'processing', 'shipped')) THEN
    FOR item IN SELECT product_id, variant_id, quantity FROM public.order_items WHERE order_id = NEW.id LOOP
      IF item.variant_id IS NOT NULL THEN
        UPDATE public.product_variants
        SET stock_quantity = stock_quantity + item.quantity
        WHERE id = item.variant_id;
      ELSE
        UPDATE public.products
        SET stock_quantity = stock_quantity + item.quantity
        WHERE id = item.product_id;
      END IF;
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_stock_change ON public.orders;

CREATE TRIGGER on_order_stock_change
  AFTER INSERT OR UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_status_stock_change();
