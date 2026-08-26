-- =========================================================================
-- SECTION 3: Triggers (updated_at + audit log)
-- =========================================================================

CREATE TRIGGER on_category_updated BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_brand_updated BEFORE UPDATE ON public.brands
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_product_updated BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE FUNCTION public.handle_admin_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_actor_id UUID;
  v_action TEXT;
  v_section TEXT;
  v_details JSONB;
BEGIN
  v_actor_id := auth.uid();
  IF TG_OP = 'INSERT' THEN
    v_action := 'INSERT';
    v_details := jsonb_build_object('new', to_jsonb(NEW));
  ELSIF TG_OP = 'UPDATE' THEN
    v_action := 'UPDATE';
    v_details := jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW));
  ELSIF TG_OP = 'DELETE' THEN
    v_action := 'DELETE';
    v_details := jsonb_build_object('old', to_jsonb(OLD));
  END IF;
  v_section := TG_TABLE_NAME;
  INSERT INTO public.admin_audit_log (actor_id, action, section, details)
  VALUES (v_actor_id, v_action, v_section, v_details);
  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$;

CREATE TRIGGER audit_category_changes AFTER INSERT OR UPDATE OR DELETE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_brand_changes AFTER INSERT OR UPDATE OR DELETE ON public.brands
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_product_changes AFTER INSERT OR UPDATE OR DELETE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_product_variant_changes AFTER INSERT OR UPDATE OR DELETE ON public.product_variants
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_product_spec_changes AFTER INSERT OR UPDATE OR DELETE ON public.product_specs
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_variant_group_changes AFTER INSERT OR UPDATE OR DELETE ON public.variant_groups
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();

CREATE TRIGGER audit_variant_option_changes AFTER INSERT OR UPDATE OR DELETE ON public.variant_options
  FOR EACH ROW EXECUTE FUNCTION public.handle_admin_audit();
