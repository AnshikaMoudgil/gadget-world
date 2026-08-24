-- =========================================================================
-- SECTION 7: Shopping Cart
-- =========================================================================
-- One cart per user (carts) holding many line items (cart_items). Line
-- items reference a product and, optionally, a specific variant.

CREATE TABLE IF NOT EXISTS public.carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT carts_user_unique UNIQUE (user_id)
);
CREATE INDEX IF NOT EXISTS idx_carts_user_id ON public.carts(user_id);

CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT cart_items_quantity_positive CHECK (quantity > 0)
);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON public.cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_variant_id ON public.cart_items(variant_id);

-- Dedupe: at most one line per (cart, product, variant). Two partial unique
-- indexes are used because a plain UNIQUE would allow duplicate rows when
-- variant_id is NULL (NULLs are never equal in a UNIQUE constraint).
CREATE UNIQUE INDEX IF NOT EXISTS cart_items_unique_with_variant
  ON public.cart_items(cart_id, product_id, variant_id)
  WHERE variant_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS cart_items_unique_no_variant
  ON public.cart_items(cart_id, product_id)
  WHERE variant_id IS NULL;


-- =========================================================================
-- Triggers (updated_at)
-- =========================================================================

CREATE TRIGGER on_cart_updated BEFORE UPDATE ON public.carts
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_cart_item_updated BEFORE UPDATE ON public.cart_items
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- =========================================================================
-- Row Level Security
-- =========================================================================
-- A cart (and its items) is private to its owner. Suspended users may still
-- read their cart but cannot modify it. Admins get read-only visibility for
-- support purposes.

ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- carts: owner full access
CREATE POLICY "Users read own cart" ON public.carts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own cart" ON public.carts
  FOR INSERT WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users update own cart" ON public.carts
  FOR UPDATE
  USING (user_id = auth.uid() AND NOT public.is_current_user_suspended())
  WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users delete own cart" ON public.carts
  FOR DELETE USING (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Admins read all carts" ON public.carts
  FOR SELECT USING (public.is_admin());

-- cart_items: access gated through ownership of the parent cart
CREATE POLICY "Users read own cart items" ON public.cart_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
  );

CREATE POLICY "Users insert own cart items" ON public.cart_items
  FOR INSERT WITH CHECK (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
  );

CREATE POLICY "Users update own cart items" ON public.cart_items
  FOR UPDATE
  USING (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
  )
  WITH CHECK (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
  );

CREATE POLICY "Users delete own cart items" ON public.cart_items
  FOR DELETE USING (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
  );

CREATE POLICY "Admins read all cart items" ON public.cart_items
  FOR SELECT USING (public.is_admin());
