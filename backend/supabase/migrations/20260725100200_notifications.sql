-- =========================================================================
-- Notifications Schema
-- =========================================================================
-- Per-user notification records for order updates, payment events,
-- support ticket replies, promotions, and system announcements.
-- =========================================================================

-- =========================================================================
-- SECTION 1: Table
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'system'
    CHECK (type IN (
      'order_update', 'payment', 'promotion',
      'support', 'system', 'delivery'
    )),
  reference_type TEXT,
  reference_id UUID,
  image_url TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Composite index for efficient "unread feed" queries:
-- SELECT * FROM notifications WHERE user_id = $1 AND is_read = false ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread_feed
  ON public.notifications(user_id, is_read, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_reference
  ON public.notifications(reference_type, reference_id)
  WHERE reference_type IS NOT NULL;


-- =========================================================================
-- SECTION 2: RPC Functions
-- =========================================================================

-- Bulk mark notifications as read (called from client with an array of IDs)
CREATE OR REPLACE FUNCTION public.mark_notifications_read(p_notification_ids UUID[])
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  UPDATE public.notifications
  SET is_read = true,
      read_at = NOW()
  WHERE id = ANY(p_notification_ids)
    AND user_id = auth.uid()
    AND is_read = false;
END;
$$;

-- Mark all notifications as read for the current user
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  UPDATE public.notifications
  SET is_read = true,
      read_at = NOW()
  WHERE user_id = auth.uid()
    AND is_read = false;
END;
$$;

-- Get unread notification count for the current user
CREATE OR REPLACE FUNCTION public.get_unread_notification_count()
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.notifications
  WHERE user_id = auth.uid()
    AND is_read = false;
$$;


-- =========================================================================
-- SECTION 3: Row Level Security
-- =========================================================================

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can read their own notifications
CREATE POLICY "Users read own notifications" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users update own notifications" ON public.notifications
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own notifications (dismiss/clear)
CREATE POLICY "Users delete own notifications" ON public.notifications
  FOR DELETE USING (user_id = auth.uid());

-- No direct insert by users — notifications are created by the system
-- (via triggers, backend functions, or admin actions)
CREATE POLICY "No direct insert by users" ON public.notifications
  FOR INSERT WITH CHECK (false);

-- Admins can read all notifications (for support/debugging)
CREATE POLICY "Admins read all notifications" ON public.notifications
  FOR SELECT USING (public.is_admin());

-- Admins can insert notifications (send to users)
CREATE POLICY "Admins insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    public.is_admin()
    AND NOT public.is_current_user_suspended()
  );

-- Admins can manage all notifications
CREATE POLICY "Admins manage all notifications" ON public.notifications
  FOR ALL
  USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
