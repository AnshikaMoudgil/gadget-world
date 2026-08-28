-- Bound every unpaid checkout to ten minutes, regardless of which checkout
-- function version originally supplied the reservation timestamp.
CREATE OR REPLACE FUNCTION public.clamp_checkout_reservation_window()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_catalog
AS $$
BEGIN
  IF NEW.status = 'pending_payment' AND NEW.payment_status = 'unpaid' THEN
    NEW.stock_reservation_expires_at := LEAST(
      COALESCE(NEW.stock_reservation_expires_at, NOW() + INTERVAL '10 minutes'),
      NOW() + INTERVAL '10 minutes'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS clamp_checkout_reservation_window ON public.orders;
CREATE TRIGGER clamp_checkout_reservation_window
BEFORE INSERT OR UPDATE OF status, payment_status, stock_reservation_expires_at
ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.clamp_checkout_reservation_window();

UPDATE public.orders
SET stock_reservation_expires_at = LEAST(
  COALESCE(stock_reservation_expires_at, created_at + INTERVAL '10 minutes'),
  created_at + INTERVAL '10 minutes'
)
WHERE status = 'pending_payment'
  AND payment_status = 'unpaid';

CREATE OR REPLACE FUNCTION public.release_expired_stock_reservations()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- REST callers must use the service role. Supabase Cron connects as postgres.
  IF auth.role() IS DISTINCT FROM 'service_role' AND session_user <> 'postgres' THEN
    RAISE EXCEPTION 'Unauthorized: only service_role or the database scheduler can release reservations';
  END IF;

  UPDATE public.orders
  SET status = 'cancelled',
      payment_status = 'failed',
      updated_at = NOW()
  WHERE status = 'pending_payment'
    AND payment_status = 'unpaid'
    AND stock_reserved = true
    AND stock_reservation_expires_at <= NOW();
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.release_expired_stock_reservations()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.release_expired_stock_reservations()
  TO service_role;

-- Supabase projects normally include pg_cron. Keep the migration portable for
-- local PostgreSQL instances where the extension is not installed.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.unschedule(jobid)
    FROM cron.job
    WHERE jobname = 'expire-unpaid-checkouts';

    PERFORM cron.schedule(
      'expire-unpaid-checkouts',
      '* * * * *',
      'SELECT public.release_expired_stock_reservations()'
    );
  END IF;
END;
$$;
