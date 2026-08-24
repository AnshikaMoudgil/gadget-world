-- =========================================================================
-- Wishlist Schema
-- =========================================================================
-- One wishlist per user (mirrors the carts pattern). Each wishlist holds
-- many wishlist_items referencing products and optionally variants.
-- =========================================================================

-- =========================================================================
-- SECTION 1: Tables
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT wishlists_user_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_wishlists_user_id ON public.wishlists(user_id);

CREATE TABLE IF NOT EXISTS public.wishlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wishlist_id UUID NOT NULL REFERENCES public.wishlists(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE,
  note TEXT,
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wishlist_items_wishlist_id ON public.wishlist_items(wishlist_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_items_product_id ON public.wishlist_items(product_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_items_variant_id ON public.wishlist_items(variant_id);

-- Dedupe: at most one entry per (wishlist, product, variant). Two partial
-- unique indexes handle the NULL variant_id case (same approach as cart_items).
CREATE UNIQUE INDEX IF NOT EXISTS wishlist_items_unique_with_variant
  ON public.wishlist_items(wishlist_id, product_id, variant_id)
  WHERE variant_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS wishlist_items_unique_no_variant
  ON public.wishlist_items(wishlist_id, product_id)
  WHERE variant_id IS NULL;


-- =========================================================================
-- SECTION 2: Triggers
-- =========================================================================

CREATE TRIGGER on_wishlist_updated BEFORE UPDATE ON public.wishlists
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-touch the parent wishlist's updated_at when items change
CREATE OR REPLACE FUNCTION public.handle_wishlist_item_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE public.wishlists SET updated_at = NOW() WHERE id = OLD.wishlist_id;
    RETURN OLD;
  ELSE
    UPDATE public.wishlists SET updated_at = NOW() WHERE id = NEW.wishlist_id;
    RETURN NEW;
  END IF;
END;
$$;

CREATE TRIGGER on_wishlist_item_changed
  AFTER INSERT OR UPDATE OR DELETE ON public.wishlist_items
  FOR EACH ROW EXECUTE FUNCTION public.handle_wishlist_item_change();


-- =========================================================================
-- SECTION 3: Row Level Security
-- =========================================================================

ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;

-- wishlists: owner full access
CREATE POLICY "Users read own wishlist" ON public.wishlists
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own wishlist" ON public.wishlists
  FOR INSERT WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users update own wishlist" ON public.wishlists
  FOR UPDATE
  USING (user_id = auth.uid() AND NOT public.is_current_user_suspended())
  WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users delete own wishlist" ON public.wishlists
  FOR DELETE USING (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Admins read all wishlists" ON public.wishlists
  FOR SELECT USING (public.is_admin());

-- wishlist_items: access gated through ownership of the parent wishlist
CREATE POLICY "Users read own wishlist items" ON public.wishlist_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.wishlists w WHERE w.id = wishlist_items.wishlist_id AND w.user_id = auth.uid())
  );

CREATE POLICY "Users insert own wishlist items" ON public.wishlist_items
  FOR INSERT WITH CHECK (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.wishlists w WHERE w.id = wishlist_items.wishlist_id AND w.user_id = auth.uid())
  );

CREATE POLICY "Users update own wishlist items" ON public.wishlist_items
  FOR UPDATE
  USING (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.wishlists w WHERE w.id = wishlist_items.wishlist_id AND w.user_id = auth.uid())
  )
  WITH CHECK (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.wishlists w WHERE w.id = wishlist_items.wishlist_id AND w.user_id = auth.uid())
  );

CREATE POLICY "Users delete own wishlist items" ON public.wishlist_items
  FOR DELETE USING (
    NOT public.is_current_user_suspended()
    AND EXISTS (SELECT 1 FROM public.wishlists w WHERE w.id = wishlist_items.wishlist_id AND w.user_id = auth.uid())
  );

CREATE POLICY "Admins read all wishlist items" ON public.wishlist_items
  FOR SELECT USING (public.is_admin());
