-- =========================================================================
-- SECTION 4: Row Level Security
-- =========================================================================

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.variant_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.variant_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.variant_combination_options ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "Public read categories" ON public.categories FOR SELECT USING (is_active = true);
CREATE POLICY "Public read brands" ON public.brands FOR SELECT USING (is_active = true);
CREATE POLICY "Public read active products" ON public.products FOR SELECT USING (is_active = true);
CREATE POLICY "Public read product variants" ON public.product_variants FOR SELECT USING (EXISTS (SELECT 1 FROM public.products p WHERE p.id = product_variants.product_id AND p.is_active = true));
CREATE POLICY "Public read product specs" ON public.product_specs FOR SELECT USING (EXISTS (SELECT 1 FROM public.products p WHERE p.id = product_specs.product_id AND p.is_active = true));
CREATE POLICY "Public read product features" ON public.product_features FOR SELECT USING (EXISTS (SELECT 1 FROM public.products p WHERE p.id = product_features.product_id AND p.is_active = true));
CREATE POLICY "Public read variant groups" ON public.variant_groups FOR SELECT USING (EXISTS (SELECT 1 FROM public.products p WHERE p.id = variant_groups.product_id AND p.is_active = true));
CREATE POLICY "Public read variant options" ON public.variant_options FOR SELECT USING (EXISTS (SELECT 1 FROM public.variant_groups vg JOIN public.products p ON p.id = vg.product_id WHERE vg.id = variant_options.group_id AND p.is_active = true));
CREATE POLICY "Public read variant combination options" ON public.variant_combination_options FOR SELECT USING (EXISTS (SELECT 1 FROM public.product_variants pv JOIN public.products p ON p.id = pv.product_id WHERE pv.id = variant_combination_options.variant_id AND p.is_active = true));

-- Admin read-all
CREATE POLICY "Admins read all categories" ON public.categories FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all brands" ON public.brands FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all products" ON public.products FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all product variants" ON public.product_variants FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all product specs" ON public.product_specs FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all product features" ON public.product_features FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all variant groups" ON public.variant_groups FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all variant options" ON public.variant_options FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins read all variant combination options" ON public.variant_combination_options FOR SELECT USING (public.is_admin());

-- Admin-only writes
CREATE POLICY "Admins manage categories" ON public.categories FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage brands" ON public.brands FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage products" ON public.products FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage product_variants" ON public.product_variants FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage product_specs" ON public.product_specs FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage product_features" ON public.product_features FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage variant_groups" ON public.variant_groups FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage variant_options" ON public.variant_options FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
CREATE POLICY "Admins manage variant_combination_options" ON public.variant_combination_options FOR ALL USING (public.is_admin() AND NOT public.is_current_user_suspended()) WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
