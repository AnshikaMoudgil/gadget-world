-- =========================================================================
-- SECTION 2: Variants
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.variant_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  group_name TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT variant_groups_display_order_positive CHECK (display_order >= 0)
);
CREATE INDEX IF NOT EXISTS idx_variant_groups_product_id ON public.variant_groups(product_id);

CREATE TABLE IF NOT EXISTS public.variant_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.variant_groups(id) ON DELETE CASCADE,
  value TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT variant_options_display_order_positive CHECK (display_order >= 0)
);
CREATE INDEX IF NOT EXISTS idx_variant_options_group_id ON public.variant_options(group_id);

CREATE TABLE IF NOT EXISTS public.product_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  sku TEXT,
  variant_name TEXT NOT NULL,
  price NUMERIC(10,2),
  images JSONB NOT NULL DEFAULT '[]'::jsonb,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT product_variants_sku_unique UNIQUE (sku),
  CONSTRAINT product_variants_price_positive CHECK (price IS NULL OR price >= 0),
  CONSTRAINT product_variants_stock_positive CHECK (stock_quantity >= 0),
  CONSTRAINT product_variants_display_order_positive CHECK (display_order >= 0),
  CONSTRAINT product_variants_images_is_array CHECK (jsonb_typeof(images) = 'array')
);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON public.product_variants(product_id);

CREATE TABLE IF NOT EXISTS public.variant_combination_options (
  variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
  option_id UUID NOT NULL REFERENCES public.variant_options(id) ON DELETE CASCADE,
  PRIMARY KEY (variant_id, option_id)
);
CREATE INDEX IF NOT EXISTS idx_vco_variant_id ON public.variant_combination_options(variant_id);
CREATE INDEX IF NOT EXISTS idx_vco_option_id ON public.variant_combination_options(option_id);
