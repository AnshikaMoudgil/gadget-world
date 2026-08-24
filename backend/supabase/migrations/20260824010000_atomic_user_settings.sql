-- Atomically initialize and return a user's settings. Concurrent first reads
-- converge on the unique user_id row instead of racing an insert.
CREATE OR REPLACE FUNCTION public.get_or_create_user_settings(p_user_id UUID)
RETURNS public.user_settings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_settings public.user_settings%ROWTYPE;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Unauthorized: only service_role can initialize settings';
  END IF;

  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'User ID is required';
  END IF;

  INSERT INTO public.user_settings (user_id)
  VALUES (p_user_id)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO STRICT v_settings
  FROM public.user_settings
  WHERE user_id = p_user_id;

  RETURN v_settings;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_or_create_user_settings(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_or_create_user_settings(UUID)
  TO service_role;
