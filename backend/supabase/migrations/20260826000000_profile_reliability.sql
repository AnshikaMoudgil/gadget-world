-- Repair profile availability for legacy and multi-provider auth users.
-- auth.users remains the identity authority; profile contact fields are display
-- data and must not prevent the auth signup trigger from creating a row.

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_email_key,
  DROP CONSTRAINT IF EXISTS profiles_phone_number_key;

CREATE OR REPLACE FUNCTION public.handle_new_user_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone_number)
  VALUES (
    NEW.id,
    NEW.email,
    NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NULLIF(NEW.phone, ''), NULLIF(NEW.raw_user_meta_data->>'phone_number', ''))
  )
  ON CONFLICT (id) DO UPDATE SET
    email = COALESCE(public.profiles.email, EXCLUDED.email),
    full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
    phone_number = COALESCE(public.profiles.phone_number, EXCLUDED.phone_number),
    updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE OF email, phone, raw_user_meta_data ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_signup();

-- Authenticated users can repair only their own missing profile. This covers
-- accounts created before the trigger was installed without allowing clients
-- to create or alter another user's row.
CREATE OR REPLACE FUNCTION public.ensure_my_profile()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_catalog
AS $$
DECLARE
  v_user auth.users%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT * INTO v_user FROM auth.users WHERE id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Authenticated user no longer exists';
  END IF;

  INSERT INTO public.profiles (id, email, full_name, phone_number)
  VALUES (
    v_user.id,
    v_user.email,
    NULLIF(v_user.raw_user_meta_data->>'full_name', ''),
    COALESCE(NULLIF(v_user.phone, ''), NULLIF(v_user.raw_user_meta_data->>'phone_number', ''))
  )
  ON CONFLICT (id) DO UPDATE SET
    email = COALESCE(public.profiles.email, EXCLUDED.email),
    full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
    phone_number = COALESCE(public.profiles.phone_number, EXCLUDED.phone_number),
    updated_at = NOW();
END;
$$;

REVOKE EXECUTE ON FUNCTION public.ensure_my_profile() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.ensure_my_profile() TO authenticated;

-- Repair every historical auth account in one pass during migration.
INSERT INTO public.profiles (id, email, full_name, phone_number)
SELECT
  u.id,
  u.email,
  NULLIF(u.raw_user_meta_data->>'full_name', ''),
  COALESCE(NULLIF(u.phone, ''), NULLIF(u.raw_user_meta_data->>'phone_number', ''))
FROM auth.users u
ON CONFLICT (id) DO UPDATE SET
  email = COALESCE(public.profiles.email, EXCLUDED.email),
  full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
  phone_number = COALESCE(public.profiles.phone_number, EXCLUDED.phone_number),
  updated_at = NOW();

NOTIFY pgrst, 'reload schema';
