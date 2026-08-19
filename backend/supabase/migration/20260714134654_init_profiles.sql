

-- =========================================================================
-- SECTION 1: Table
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT UNIQUE,
  phone_number TEXT UNIQUE,
  date_of_birth DATE,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'superadmin')),
  is_suspended BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Generic updated_at trigger function. Defined here (the first migration)
-- so this trigger and every later catalog migration can rely on it.
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

CREATE TRIGGER on_profile_updated BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- =========================================================================
-- SECTION 2: Helper Functions (SECURITY DEFINER — avoid RLS recursion)
-- =========================================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin')) $$;

CREATE OR REPLACE FUNCTION public.is_superadmin()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'superadmin') $$;

CREATE OR REPLACE FUNCTION public.is_current_user_suspended()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_suspended = true) $$;

CREATE OR REPLACE FUNCTION public.is_target_not_superadmin(target_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = target_id AND role = 'superadmin') $$;


-- =========================================================================
-- SECTION 3: Auto-create profile row on signup
-- =========================================================================
-- Since direct INSERT from clients is blocked below, something has to
-- create the profiles row when someone signs up. This trigger on
-- auth.users (Supabase's built-in signup table) does that automatically.

CREATE OR REPLACE FUNCTION public.handle_new_user_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NULL)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Attach to auth.users — fires every time someone signs up (Google or Email)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_signup();


-- =========================================================================
-- SECTION 4: Row Level Security Policies
-- =========================================================================

-- SELECT
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (public.is_admin() AND NOT public.is_current_user_suspended());

-- INSERT — blocked. Rows are created only via the signup trigger above.
CREATE POLICY "No direct insert by users" ON public.profiles
  FOR INSERT WITH CHECK (false);

-- UPDATE — self update, role frozen (can't self-promote)
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id AND NOT public.is_current_user_suspended())
  WITH CHECK (
    auth.uid() = id
    AND NOT public.is_current_user_suspended()
    AND role = (SELECT role FROM public.profiles WHERE id = auth.uid())
  );

-- UPDATE — admins can update anyone except a superadmin
CREATE POLICY "Admins can update non-superadmin profiles" ON public.profiles
  FOR UPDATE
  USING (public.is_admin() AND public.is_target_not_superadmin(id) AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND public.is_target_not_superadmin(id) AND NOT public.is_current_user_suspended());

-- UPDATE — superadmins can update anyone, including other superadmins
CREATE POLICY "Superadmins can update any profile" ON public.profiles
  FOR UPDATE
  USING (public.is_superadmin())
  WITH CHECK (public.is_superadmin());

-- DELETE — users can never delete their own profile row directly
CREATE POLICY "No delete by users" ON public.profiles
  FOR DELETE USING (false);

-- DELETE — admins can delete anyone except a superadmin
CREATE POLICY "Admins can delete non-superadmin profiles" ON public.profiles
  FOR DELETE USING (public.is_admin() AND public.is_target_not_superadmin(id));

-- DELETE — superadmins can delete anyone
CREATE POLICY "Superadmins can delete any profile" ON public.profiles
  FOR DELETE USING (public.is_superadmin());


-- =========================================================================
-- SECTION 5: Admin Audit Log (unchanged from before)
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID,
  action TEXT NOT NULL,
  section TEXT NOT NULL,
  details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins read audit log" ON public.admin_audit_log
  FOR SELECT USING (public.is_admin());

CREATE POLICY "No direct insert audit log" ON public.admin_audit_log
  FOR INSERT WITH CHECK (false);
