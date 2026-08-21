-- Atomic, server-only checkout creation with authoritative catalog validation,
-- address snapshots, and inventory reservation.
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS shipping_address_snapshot JSONB,
  ADD COLUMN IF NOT EXISTS stock_reserved BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS stock_reservation_expires_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_orders_expired_stock_reservations
  ON public.orders(stock_reservation_expires_at)
  WHERE stock_reserved = true AND status = 'pending_payment';

DROP FUNCTION IF EXISTS public.create_razorpay_checkout(
  UUID, UUID, UUID, TEXT, TEXT, NUMERIC, TEXT
);

CREATE FUNCTION public.create_razorpay_checkout(
  p_user_id UUID,
  p_cart_id UUID,
  p_address_id UUID,
  p_razorpay_order_id TEXT,
  p_currency TEXT,
  p_expected_amount NUMERIC,
  p_coupon_code TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_address public.user_addresses%ROWTYPE;
  v_cart_item RECORD;
  v_product public.products%ROWTYPE;
  v_variant public.product_variants%ROWTYPE;
  v_coupon public.coupons%ROWTYPE;
  v_order_id UUID;
  v_item_count INTEGER := 0;
  v_usage_count INTEGER;
  v_subtotal NUMERIC(10,2) := 0;
  v_shipping_fee NUMERIC(10,2) := 0;
  v_discount NUMERIC(10,2) := 0;
  v_total NUMERIC(10,2);
  v_unit_price NUMERIC(10,2);
  v_coupon_code TEXT;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized: only service_role can create checkouts';
  END IF;

  IF p_user_id IS NULL OR p_cart_id IS NULL OR p_address_id IS NULL OR
     p_razorpay_order_id IS NULL OR btrim(p_razorpay_order_id) = '' OR
     p_currency IS NULL OR btrim(p_currency) = '' OR
     p_expected_amount IS NULL OR p_expected_amount <= 0 THEN
    RAISE EXCEPTION 'Invalid checkout parameters';
  END IF;

  PERFORM 1 FROM public.carts
  WHERE id = p_cart_id AND user_id = p_user_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart does not belong to the supplied user';
  END IF;

  SELECT * INTO v_address
  FROM public.user_addresses
  WHERE id = p_address_id AND user_id = p_user_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Shipping address does not belong to the supplied user';
  END IF;

  -- Lock authoritative catalog rows and calculate the current subtotal.
  FOR v_cart_item IN
    SELECT id, product_id, variant_id, quantity
    FROM public.cart_items
    WHERE cart_id = p_cart_id
    ORDER BY id
  LOOP
    v_item_count := v_item_count + 1;
    IF v_cart_item.quantity <= 0 THEN
      RAISE EXCEPTION 'Cart contains an invalid quantity';
    END IF;

    SELECT * INTO v_product FROM public.products
    WHERE id = v_cart_item.product_id
    FOR UPDATE;
    IF NOT FOUND OR NOT v_product.is_active THEN
      RAISE EXCEPTION 'Cart contains an unavailable product';
    END IF;

    IF v_cart_item.variant_id IS NOT NULL THEN
      SELECT * INTO v_variant FROM public.product_variants
      WHERE id = v_cart_item.variant_id
        AND product_id = v_cart_item.product_id
      FOR UPDATE;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'Variant does not belong to the cart product';
      END IF;
      IF v_variant.stock_quantity < v_cart_item.quantity THEN
        RAISE EXCEPTION 'Insufficient variant stock for product %', v_product.name;
      END IF;
      v_unit_price := COALESCE(v_variant.price, v_product.price);
    ELSE
      IF EXISTS (
        SELECT 1 FROM public.product_variants
        WHERE product_id = v_cart_item.product_id
      ) THEN
        RAISE EXCEPTION 'A variant is required for product %', v_product.name;
      END IF;
      IF v_product.stock_quantity < v_cart_item.quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %', v_product.name;
      END IF;
      v_unit_price := v_product.price;
    END IF;

    v_subtotal := v_subtotal + (v_unit_price * v_cart_item.quantity);
  END LOOP;

  IF v_item_count = 0 OR v_subtotal <= 0 THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;

  v_shipping_fee := CASE WHEN v_subtotal > 50000 THEN 0 ELSE 299 END;
  v_coupon_code := NULLIF(upper(btrim(p_coupon_code)), '');

  IF v_coupon_code IS NOT NULL THEN
    SELECT * INTO v_coupon FROM public.coupons
    WHERE code = v_coupon_code
    FOR UPDATE;
    IF NOT FOUND OR NOT v_coupon.is_active OR
       (v_coupon.valid_from IS NOT NULL AND v_coupon.valid_from > NOW()) OR
       (v_coupon.valid_until IS NOT NULL AND v_coupon.valid_until <= NOW()) OR
       v_subtotal < v_coupon.min_order_value OR
       (v_coupon.total_usage_limit IS NOT NULL AND
        v_coupon.times_used >= v_coupon.total_usage_limit) THEN
      RAISE EXCEPTION 'Coupon is not valid for this checkout';
    END IF;

    IF v_coupon.usage_limit_per_user IS NOT NULL THEN
      SELECT count(*) INTO v_usage_count FROM public.user_coupons
      WHERE coupon_id = v_coupon.id AND user_id = p_user_id;
      IF v_usage_count >= v_coupon.usage_limit_per_user THEN
        RAISE EXCEPTION 'Coupon usage limit reached';
      END IF;
    END IF;

    CASE v_coupon.discount_type
      WHEN 'percentage' THEN
        v_discount := (v_subtotal * v_coupon.discount_value) / 100;
        IF v_coupon.max_discount_amount IS NOT NULL THEN
          v_discount := LEAST(v_discount, v_coupon.max_discount_amount);
        END IF;
      WHEN 'fixed_amount' THEN
        v_discount := LEAST(v_coupon.discount_value, v_subtotal);
      WHEN 'free_shipping' THEN
        v_shipping_fee := 0;
      ELSE
        RAISE EXCEPTION 'Unsupported coupon type';
    END CASE;
  END IF;

  v_total := round(v_subtotal + v_shipping_fee - v_discount, 2);
  IF v_total IS DISTINCT FROM round(p_expected_amount, 2) THEN
    RAISE EXCEPTION 'Checkout amount changed; create a new Razorpay order';
  END IF;

  INSERT INTO public.orders (
    user_id, shipping_address_id, shipping_address_snapshot, status,
    payment_status, payment_method, total_amount, subtotal, shipping_fee,
    discount_amount, coupon_code, stock_reserved,
    stock_reservation_expires_at
  ) VALUES (
    p_user_id,
    p_address_id,
    jsonb_build_object(
      'id', v_address.id,
      'recipient_name', v_address.recipient_name,
      'phone_number', v_address.phone_number,
      'address_line1', v_address.address_line1,
      'address_line2', v_address.address_line2,
      'landmark', v_address.landmark,
      'city', v_address.city,
      'state', v_address.state,
      'postal_code', v_address.postal_code,
      'country', v_address.country,
      'address_type', v_address.address_type
    ),
    'pending_payment', 'unpaid', 'razorpay', v_total, v_subtotal,
    v_shipping_fee, v_discount, v_coupon_code, true, NOW() + INTERVAL '30 minutes'
  ) RETURNING id INTO v_order_id;

  -- Insert every line and reserve its stock in this same transaction.
  FOR v_cart_item IN
    SELECT ci.product_id, ci.variant_id, ci.quantity,
           p.name AS product_name, p.price AS product_price,
           pv.variant_name, pv.price AS variant_price
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    LEFT JOIN public.product_variants pv ON pv.id = ci.variant_id
    WHERE ci.cart_id = p_cart_id
    ORDER BY ci.id
  LOOP
    v_unit_price := COALESCE(v_cart_item.variant_price, v_cart_item.product_price);
    INSERT INTO public.order_items (
      order_id, product_id, variant_id, product_name, variant_name,
      quantity, unit_price, total_price
    ) VALUES (
      v_order_id, v_cart_item.product_id, v_cart_item.variant_id,
      v_cart_item.product_name, v_cart_item.variant_name, v_cart_item.quantity,
      v_unit_price, v_unit_price * v_cart_item.quantity
    );

    IF v_cart_item.variant_id IS NOT NULL THEN
      UPDATE public.product_variants
      SET stock_quantity = stock_quantity - v_cart_item.quantity
      WHERE id = v_cart_item.variant_id;
    ELSE
      UPDATE public.products
      SET stock_quantity = stock_quantity - v_cart_item.quantity
      WHERE id = v_cart_item.product_id;
    END IF;
  END LOOP;

  INSERT INTO public.payments (
    order_id, provider, razorpay_order_id, amount, currency, status
  ) VALUES (
    v_order_id, 'razorpay', p_razorpay_order_id, v_total, upper(p_currency), 'created'
  );

  IF v_coupon_code IS NOT NULL THEN
    INSERT INTO public.user_coupons(user_id, coupon_id, order_id)
    VALUES (p_user_id, v_coupon.id, v_order_id);
    UPDATE public.coupons SET times_used = times_used + 1
    WHERE id = v_coupon.id;
  END IF;

  RETURN jsonb_build_object(
    'order_id', v_order_id,
    'subtotal', v_subtotal,
    'shipping_fee', v_shipping_fee,
    'discount_amount', v_discount,
    'total_amount', v_total
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_razorpay_checkout(
  UUID, UUID, UUID, TEXT, TEXT, NUMERIC, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_razorpay_checkout(
  UUID, UUID, UUID, TEXT, TEXT, NUMERIC, TEXT
) TO service_role;

-- New checkouts reserve stock at creation. Keep confirmation compatible with
-- legacy pending orders that have not reserved stock yet, and restore a
-- reservation exactly once on cancellation.
CREATE OR REPLACE FUNCTION public.handle_order_status_stock_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  item RECORD;
  v_updated INTEGER;
  v_coupon_id UUID;
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status = 'confirmed' AND
     OLD.status IN ('pending_payment', 'pending') AND NOT OLD.stock_reserved THEN
    FOR item IN SELECT product_id, variant_id, quantity
                FROM public.order_items WHERE order_id = NEW.id LOOP
      IF item.variant_id IS NOT NULL THEN
        UPDATE public.product_variants
        SET stock_quantity = stock_quantity - item.quantity
        WHERE id = item.variant_id AND stock_quantity >= item.quantity;
      ELSE
        UPDATE public.products
        SET stock_quantity = stock_quantity - item.quantity
        WHERE id = item.product_id AND stock_quantity >= item.quantity;
      END IF;
      GET DIAGNOSTICS v_updated = ROW_COUNT;
      IF v_updated <> 1 THEN
        RAISE EXCEPTION 'Insufficient stock while confirming order';
      END IF;
    END LOOP;
    NEW.stock_reserved := true;
  END IF;

  IF TG_OP = 'UPDATE' AND NEW.status = 'cancelled' AND OLD.stock_reserved THEN
    FOR item IN SELECT product_id, variant_id, quantity
                FROM public.order_items WHERE order_id = NEW.id LOOP
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
    NEW.stock_reserved := false;

    -- A cancelled/expired checkout must not consume coupon allowance.
    DELETE FROM public.user_coupons
    WHERE order_id = NEW.id
    RETURNING coupon_id INTO v_coupon_id;
    IF v_coupon_id IS NOT NULL THEN
      UPDATE public.coupons
      SET times_used = GREATEST(0, times_used - 1)
      WHERE id = v_coupon_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_stock_change ON public.orders;
CREATE TRIGGER on_order_stock_change
  BEFORE UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_status_stock_change();

CREATE OR REPLACE FUNCTION public.release_expired_stock_reservations()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized: only service_role can release reservations';
  END IF;
  UPDATE public.orders
  SET status = 'cancelled', updated_at = NOW()
  WHERE status = 'pending_payment'
    AND payment_status = 'unpaid'
    AND stock_reserved = true
    AND stock_reservation_expires_at <= NOW();
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.release_expired_stock_reservations()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.release_expired_stock_reservations()
  TO service_role;
