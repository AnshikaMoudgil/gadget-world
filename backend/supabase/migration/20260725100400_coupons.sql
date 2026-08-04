-- =========================================================================
-- SECTION: Coupons & User Coupons
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_shipping')),
  discount_value NUMERIC(10,2) NOT NULL CHECK (discount_value >= 0),
  min_order_value NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (min_order_value >= 0),
  max_discount_amount NUMERIC(10,2) CHECK (max_discount_amount >= 0),
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  usage_limit_per_user INTEGER,
  total_usage_limit INTEGER,
  times_used INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coupons_code ON public.coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON public.coupons(is_active);

CREATE TABLE IF NOT EXISTS public.user_coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  coupon_id UUID NOT NULL REFERENCES public.coupons(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  used_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_coupons_user_id ON public.user_coupons(user_id);
CREATE INDEX IF NOT EXISTS idx_user_coupons_coupon_id ON public.user_coupons(coupon_id);

-- Alter orders table to include coupon info
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS coupon_code TEXT,
ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0;

-- Triggers for updated_at
CREATE TRIGGER on_coupon_updated BEFORE UPDATE ON public.coupons
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_coupons ENABLE ROW LEVEL SECURITY;

-- Admins can do everything
CREATE POLICY "Admins can do everything on coupons" ON public.coupons
  FOR ALL USING (public.is_admin());

CREATE POLICY "Admins can do everything on user_coupons" ON public.user_coupons
  FOR ALL USING (public.is_admin());

-- Users can read active coupons (for listing available coupons, if we want them to)
CREATE POLICY "Users can read active coupons" ON public.coupons
  FOR SELECT USING (is_active = true AND (valid_until IS NULL OR valid_until > NOW()));

-- Users can read their own usage history
CREATE POLICY "Users can view own usage history" ON public.user_coupons
  FOR SELECT USING (auth.uid() = user_id);

-- Seed some sample coupons
INSERT INTO public.coupons (code, discount_type, discount_value, min_order_value, max_discount_amount, is_active, usage_limit_per_user)
VALUES
  ('SUMMER50', 'percentage', 20, 1000, 500, true, 1),
  ('FLAT200', 'fixed_amount', 200, 1500, NULL, true, NULL),
  ('FREESHIP', 'free_shipping', 0, 500, NULL, true, NULL)
ON CONFLICT (code) DO NOTHING;
