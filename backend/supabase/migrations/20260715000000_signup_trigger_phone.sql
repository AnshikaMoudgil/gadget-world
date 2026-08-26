-- Update the signup trigger so the auto-created profile row also captures
-- the phone number (from auth.users.phone for OTP signups, or from the
-- signup metadata for email signups that collect a mobile number).

CREATE OR REPLACE FUNCTION public.handle_new_user_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone_number)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NULL),
    COALESCE(NULLIF(NEW.phone, ''), NEW.raw_user_meta_data->>'phone_number')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Backfill: create profile rows for any auth users that signed up before
-- the trigger existed (they currently have no profiles row at all).
INSERT INTO public.profiles (id, email, full_name, phone_number)
SELECT
  u.id,
  u.email,
  u.raw_user_meta_data->>'full_name',
  COALESCE(NULLIF(u.phone, ''), u.raw_user_meta_data->>'phone_number')
FROM auth.users u
ON CONFLICT (id) DO NOTHING;
