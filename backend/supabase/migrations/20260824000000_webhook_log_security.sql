-- Webhook audit records contain only minimized payment metadata, are visible
-- only to the backend service role, and are retained for at most 30 days.
ALTER TABLE public.webhook_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_logs FORCE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.webhook_logs FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.webhook_logs TO service_role;

CREATE OR REPLACE FUNCTION public.enforce_webhook_log_retention()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  DELETE FROM public.webhook_logs
  WHERE created_at < NOW() - INTERVAL '30 days';
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS webhook_logs_retention_on_insert ON public.webhook_logs;
CREATE TRIGGER webhook_logs_retention_on_insert
  AFTER INSERT ON public.webhook_logs
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.enforce_webhook_log_retention();

REVOKE ALL ON FUNCTION public.enforce_webhook_log_retention() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.enforce_webhook_log_retention() TO service_role;

-- Remove legacy raw payloads already stored before payload minimization. This
-- keeps event identity/status while eliminating customer/provider response data.
UPDATE public.webhook_logs
SET payload = '{}'::jsonb
WHERE payload <> '{}'::jsonb;
