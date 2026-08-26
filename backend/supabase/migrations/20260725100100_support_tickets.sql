-- =========================================================================
-- Support Tickets & Messages Schema
-- =========================================================================
-- Users can raise support tickets (optionally linked to an order).
-- Each ticket has a threaded conversation of messages between the user
-- and admin/support staff.
-- =========================================================================

-- =========================================================================
-- SECTION 1: Tables
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  ticket_number TEXT NOT NULL UNIQUE
    DEFAULT ('ST-' || UPPER(SUBSTRING(gen_random_uuid()::text FROM 1 FOR 8))),
  subject TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general'
    CHECK (category IN (
      'general', 'order_issue', 'payment', 'delivery',
      'return_refund', 'product', 'account', 'other'
    )),
  status TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'in_progress', 'waiting_customer', 'resolved', 'closed')),
  priority TEXT NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_order_id ON public.support_tickets(order_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON public.support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_priority ON public.support_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON public.support_tickets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_tickets_assigned_to ON public.support_tickets(assigned_to);

CREATE TABLE IF NOT EXISTS public.support_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_role TEXT NOT NULL DEFAULT 'customer'
    CHECK (sender_role IN ('customer', 'admin')),
  message TEXT NOT NULL,
  attachments JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_internal BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT support_messages_attachments_is_array
    CHECK (jsonb_typeof(attachments) = 'array')
);

CREATE INDEX IF NOT EXISTS idx_support_messages_ticket_id ON public.support_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_sender_id ON public.support_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_created_at ON public.support_messages(created_at);


-- =========================================================================
-- SECTION 2: Triggers
-- =========================================================================

CREATE TRIGGER on_support_ticket_updated BEFORE UPDATE ON public.support_tickets
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-update ticket's updated_at when a new message is added
CREATE OR REPLACE FUNCTION public.handle_support_message_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE public.support_tickets
    SET updated_at = NOW()
    WHERE id = NEW.ticket_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_support_message_inserted
  AFTER INSERT ON public.support_messages
  FOR EACH ROW EXECUTE FUNCTION public.handle_support_message_insert();

-- Auto-set resolved_at timestamp when ticket status changes to 'resolved'
CREATE OR REPLACE FUNCTION public.handle_ticket_resolved()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status = 'resolved' AND (OLD.status IS DISTINCT FROM 'resolved') THEN
    NEW.resolved_at = NOW();
  END IF;
  IF NEW.status <> 'resolved' AND OLD.status = 'resolved' THEN
    NEW.resolved_at = NULL;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_ticket_status_resolved
  BEFORE UPDATE OF status ON public.support_tickets
  FOR EACH ROW EXECUTE FUNCTION public.handle_ticket_resolved();


-- =========================================================================
-- SECTION 3: Row Level Security
-- =========================================================================

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- support_tickets: users see own tickets
CREATE POLICY "Users read own support tickets" ON public.support_tickets
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own support tickets" ON public.support_tickets
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND NOT public.is_current_user_suspended()
  );

-- Users can update their own tickets (e.g., add info, re-open)
-- but cannot change priority or assigned_to (those are admin-only fields
-- enforced at the application layer)
CREATE POLICY "Users update own support tickets" ON public.support_tickets
  FOR UPDATE
  USING (user_id = auth.uid() AND NOT public.is_current_user_suspended())
  WITH CHECK (user_id = auth.uid() AND NOT public.is_current_user_suspended());

-- Admins: full access to all tickets
CREATE POLICY "Admins manage all support tickets" ON public.support_tickets
  FOR ALL
  USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());

-- support_messages: users see messages on their own tickets (excluding internal notes)
CREATE POLICY "Users read own ticket messages" ON public.support_messages
  FOR SELECT USING (
    is_internal = false
    AND EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = support_messages.ticket_id
        AND t.user_id = auth.uid()
    )
  );

CREATE POLICY "Users insert messages on own tickets" ON public.support_messages
  FOR INSERT WITH CHECK (
    NOT public.is_current_user_suspended()
    AND sender_id = auth.uid()
    AND sender_role = 'customer'
    AND is_internal = false
    AND EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = support_messages.ticket_id
        AND t.user_id = auth.uid()
    )
  );

-- Admins: full access to all messages (including internal notes)
CREATE POLICY "Admins manage all support messages" ON public.support_messages
  FOR ALL
  USING (public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (public.is_admin() AND NOT public.is_current_user_suspended());
