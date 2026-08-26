-- Bound common catalog filters with supporting partial indexes.
CREATE INDEX IF NOT EXISTS idx_products_active_created_at
  ON public.products(created_at DESC) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_products_active_price
  ON public.products(price) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_products_active_stock
  ON public.products(stock_quantity) WHERE is_active = true;

-- Cart writes go through the server-only functions below. Keeping direct user
-- SELECT access is harmless, but direct mutations would bypass atomicity.
DROP POLICY IF EXISTS "Users insert own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users update own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users delete own cart items" ON public.cart_items;

CREATE OR REPLACE FUNCTION public.guard_cart_item_integrity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_product public.products%ROWTYPE;
  v_variant public.product_variants%ROWTYPE;
BEGIN
  IF NEW.quantity < 1 OR NEW.quantity > 99 THEN
    RAISE EXCEPTION 'Cart quantity must be between 1 and 99';
  END IF;

  SELECT * INTO v_product FROM public.products
  WHERE id = NEW.product_id AND is_active = true
  FOR SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Product is unavailable';
  END IF;

  IF NEW.variant_id IS NOT NULL THEN
    SELECT * INTO v_variant FROM public.product_variants
    WHERE id = NEW.variant_id AND product_id = NEW.product_id
    FOR SHARE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Variant does not belong to product';
    END IF;
    IF v_variant.stock_quantity < NEW.quantity THEN
      RAISE EXCEPTION 'Requested quantity exceeds variant stock';
    END IF;
  ELSE
    IF EXISTS (
      SELECT 1 FROM public.product_variants WHERE product_id = NEW.product_id
    ) THEN
      RAISE EXCEPTION 'A variant is required for this product';
    END IF;
    IF v_product.stock_quantity < NEW.quantity THEN
      RAISE EXCEPTION 'Requested quantity exceeds product stock';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS guard_cart_item_integrity ON public.cart_items;
CREATE TRIGGER guard_cart_item_integrity
  BEFORE INSERT OR UPDATE OF product_id, variant_id, quantity
  ON public.cart_items
  FOR EACH ROW EXECUTE FUNCTION public.guard_cart_item_integrity();

CREATE OR REPLACE FUNCTION public.add_cart_item(
  p_user_id UUID,
  p_product_id UUID,
  p_variant_id UUID,
  p_quantity INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_cart_id UUID;
  v_updated INTEGER;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  IF p_quantity < 1 OR p_quantity > 99 THEN
    RAISE EXCEPTION 'Cart quantity must be between 1 and 99';
  END IF;

  INSERT INTO public.carts(user_id) VALUES (p_user_id)
  ON CONFLICT (user_id) DO UPDATE SET user_id = EXCLUDED.user_id
  RETURNING id INTO v_cart_id;

  IF p_variant_id IS NOT NULL THEN
    INSERT INTO public.cart_items(cart_id, product_id, variant_id, quantity)
    VALUES (v_cart_id, p_product_id, p_variant_id, p_quantity)
    ON CONFLICT (cart_id, product_id, variant_id)
      WHERE variant_id IS NOT NULL
    DO UPDATE SET quantity = public.cart_items.quantity + EXCLUDED.quantity
    WHERE public.cart_items.quantity + EXCLUDED.quantity <= 99;
  ELSE
    INSERT INTO public.cart_items(cart_id, product_id, quantity)
    VALUES (v_cart_id, p_product_id, p_quantity)
    ON CONFLICT (cart_id, product_id)
      WHERE variant_id IS NULL
    DO UPDATE SET quantity = public.cart_items.quantity + EXCLUDED.quantity
    WHERE public.cart_items.quantity + EXCLUDED.quantity <= 99;
  END IF;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 1 THEN
    RAISE EXCEPTION 'Cart quantity cannot exceed 99';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_cart_item_quantity(
  p_user_id UUID,
  p_cart_item_id UUID,
  p_quantity INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  IF p_quantity < 1 OR p_quantity > 99 THEN
    RAISE EXCEPTION 'Cart quantity must be between 1 and 99';
  END IF;

  UPDATE public.cart_items ci
  SET quantity = p_quantity
  FROM public.carts c
  WHERE ci.id = p_cart_item_id
    AND c.id = ci.cart_id
    AND c.user_id = p_user_id;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 1 THEN
    RAISE EXCEPTION 'Cart item not found';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.remove_cart_item(
  p_user_id UUID,
  p_cart_item_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_deleted INTEGER;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  DELETE FROM public.cart_items ci
  USING public.carts c
  WHERE ci.id = p_cart_item_id
    AND c.id = ci.cart_id
    AND c.user_id = p_user_id;
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  IF v_deleted <> 1 THEN
    RAISE EXCEPTION 'Cart item not found';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.add_cart_item(UUID, UUID, UUID, INTEGER)
  FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.set_cart_item_quantity(UUID, UUID, INTEGER)
  FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.remove_cart_item(UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.add_cart_item(UUID, UUID, UUID, INTEGER)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.set_cart_item_quantity(UUID, UUID, INTEGER)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.remove_cart_item(UUID, UUID)
  TO service_role;
