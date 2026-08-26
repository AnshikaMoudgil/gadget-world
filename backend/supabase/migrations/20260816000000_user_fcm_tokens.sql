-- =========================================================================
-- User FCM Tokens Schema
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON public.user_fcm_tokens(user_id);

-- RLS
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can insert/upsert their own tokens
CREATE POLICY "Users can insert own fcm tokens" ON public.user_fcm_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can read their own tokens
CREATE POLICY "Users can read own fcm tokens" ON public.user_fcm_tokens
  FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own tokens
CREATE POLICY "Users can update own fcm tokens" ON public.user_fcm_tokens
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tokens
CREATE POLICY "Users can delete own fcm tokens" ON public.user_fcm_tokens
  FOR DELETE USING (auth.uid() = user_id);

-- Admins can read all tokens for pushing notifications
CREATE POLICY "Admins can read all tokens" ON public.user_fcm_tokens
  FOR SELECT USING (public.is_admin());
