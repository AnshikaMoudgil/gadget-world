INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('products', 'products', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('categories', 'categories', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('brands', 'brands', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public catalog images access" ON storage.objects;
DROP POLICY IF EXISTS "Admins manage catalog images" ON storage.objects;
CREATE POLICY "Public catalog images access" ON storage.objects
  FOR SELECT USING (bucket_id IN ('products', 'categories', 'brands'));
CREATE POLICY "Admins manage catalog images" ON storage.objects
  FOR ALL
  USING (bucket_id IN ('products', 'categories', 'brands') AND public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (bucket_id IN ('products', 'categories', 'brands') AND public.is_admin() AND NOT public.is_current_user_suspended());

CREATE TABLE IF NOT EXISTS public.webhook_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  razorpay_event_id TEXT UNIQUE,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  signature_verified BOOLEAN NOT NULL DEFAULT false,
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.webhook_logs ADD COLUMN IF NOT EXISTS processing_started_at TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.claim_razorpay_webhook(p_event_id TEXT, p_event_type TEXT, p_payload JSONB)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_catalog AS $$
DECLARE v_claimed UUID;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Unauthorized'; END IF;
  IF p_event_id IS NULL OR btrim(p_event_id) = '' OR length(p_event_id) > 200 THEN
    RAISE EXCEPTION 'Invalid webhook event ID';
  END IF;
  INSERT INTO public.webhook_logs (razorpay_event_id, event_type, payload, signature_verified, processing_started_at)
  VALUES (p_event_id, p_event_type, p_payload, true, NOW())
  ON CONFLICT (razorpay_event_id) DO UPDATE
    SET event_type = EXCLUDED.event_type, payload = EXCLUDED.payload,
        signature_verified = true, processing_started_at = NOW()
    WHERE webhook_logs.processed_at IS NULL
      AND (webhook_logs.processing_started_at IS NULL OR webhook_logs.processing_started_at < NOW() - INTERVAL '5 minutes')
  RETURNING id INTO v_claimed;
  RETURN v_claimed IS NOT NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_razorpay_webhook(p_event_id TEXT)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Unauthorized'; END IF;
  UPDATE public.webhook_logs SET processed_at = NOW(), processing_started_at = NULL
  WHERE razorpay_event_id = p_event_id AND processed_at IS NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.release_razorpay_webhook(p_event_id TEXT)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Unauthorized'; END IF;
  UPDATE public.webhook_logs SET processing_started_at = NULL
  WHERE razorpay_event_id = p_event_id AND processed_at IS NULL;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.claim_razorpay_webhook(TEXT, TEXT, JSONB) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.complete_razorpay_webhook(TEXT) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.release_razorpay_webhook(TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_razorpay_webhook(TEXT, TEXT, JSONB) TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_razorpay_webhook(TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.release_razorpay_webhook(TEXT) TO service_role;
