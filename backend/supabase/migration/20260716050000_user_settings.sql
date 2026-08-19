-- =========================================================================
-- SECTION 5: User Settings & Preferences
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,
  order_updates_sms BOOLEAN NOT NULL DEFAULT true,
  order_updates_email BOOLEAN NOT NULL DEFAULT true,
  promotions_email BOOLEAN NOT NULL DEFAULT false,
  preferred_theme TEXT NOT NULL DEFAULT 'system' CHECK (preferred_theme IN ('light', 'dark', 'system')),
  preferred_language TEXT NOT NULL DEFAULT 'en',
  fcm_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT user_settings_user_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON public.user_settings(user_id);

-- Trigger for updated_at
CREATE TRIGGER on_user_settings_updated BEFORE UPDATE ON public.user_settings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-create default settings row when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user_settings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_settings ON auth.users;
CREATE TRIGGER on_auth_user_created_settings
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_settings();

-- =========================================================================
-- Row Level Security (RLS)
-- =========================================================================

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own settings" ON public.user_settings
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own settings" ON public.user_settings
  FOR INSERT WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users update own settings" ON public.user_settings
  FOR UPDATE
  USING (user_id = auth.uid() AND NOT public.is_current_user_suspended())
  WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Admins read all settings" ON public.user_settings
  FOR SELECT USING (public.is_admin());
