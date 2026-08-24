-- =========================================================================
-- SECTION 8: User Shipping Addresses
-- =========================================================================
-- A customer can save multiple shipping addresses. Exactly one may be
-- flagged as the default (enforced by a partial unique index below).

CREATE TABLE IF NOT EXISTS public.user_addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  landmark TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'India',
  address_type TEXT NOT NULL DEFAULT 'home',
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT user_addresses_type_check CHECK (address_type IN ('home', 'work', 'other')),
  CONSTRAINT user_addresses_postal_code_format CHECK (postal_code ~ '^[1-9][0-9]{5}$')
);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON public.user_addresses(user_id);

-- At most one default address per user.
CREATE UNIQUE INDEX IF NOT EXISTS user_addresses_one_default_per_user
  ON public.user_addresses(user_id)
  WHERE is_default = true;


-- =========================================================================
-- Triggers (updated_at + single default)
-- =========================================================================

CREATE TRIGGER on_user_address_updated BEFORE UPDATE ON public.user_addresses
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- When a row is flagged as the default, demote the user's previous default
-- so the app can just set is_default = true without first clearing the old
-- one (and never trips user_addresses_one_default_per_user). Setting the
-- new default to false first avoids re-firing on the demoted rows.
CREATE OR REPLACE FUNCTION public.handle_default_address()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE public.user_addresses
    SET is_default = false
    WHERE user_id = NEW.user_id
      AND id <> NEW.id
      AND is_default = true;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_user_address_default_set
  BEFORE INSERT OR UPDATE OF is_default ON public.user_addresses
  FOR EACH ROW
  WHEN (NEW.is_default = true)
  EXECUTE FUNCTION public.handle_default_address();


-- =========================================================================
-- Row Level Security
-- =========================================================================
-- Addresses are private to their owner. Suspended users may read their
-- addresses but cannot modify them. Admins get read-only visibility for
-- support / order fulfilment.

ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own addresses" ON public.user_addresses
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own addresses" ON public.user_addresses
  FOR INSERT WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users update own addresses" ON public.user_addresses
  FOR UPDATE
  USING (user_id = auth.uid() AND NOT public.is_current_user_suspended())
  WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Users delete own addresses" ON public.user_addresses
  FOR DELETE USING (user_id = auth.uid() AND NOT public.is_current_user_suspended());

CREATE POLICY "Admins read all addresses" ON public.user_addresses
  FOR SELECT USING (public.is_admin());
