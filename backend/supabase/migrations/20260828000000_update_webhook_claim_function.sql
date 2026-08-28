-- Update the claim_razorpay_webhook function to accept a signature_verified parameter
CREATE OR REPLACE FUNCTION public.claim_razorpay_webhook(p_event_id TEXT, p_event_type TEXT, p_payload JSONB, p_signature_verified BOOLEAN DEFAULT true)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_catalog AS $$
DECLARE v_claimed UUID;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Unauthorized'; END IF;
  IF p_event_id IS NULL OR btrim(p_event_id) = '' OR length(p_event_id) > 200 THEN
    RAISE EXCEPTION 'Invalid webhook event ID';
  END IF;
  INSERT INTO public.webhook_logs (razorpay_event_id, event_type, payload, signature_verified, processing_started_at)
  VALUES (p_event_id, p_event_type, p_payload, p_signature_verified, NOW())
  ON CONFLICT (razorpay_event_id) DO UPDATE
    SET event_type = EXCLUDED.event_type, payload = EXCLUDED.payload,
        signature_verified = p_signature_verified, processing_started_at = NOW()
    WHERE webhook_logs.processed_at IS NULL
      AND (webhook_logs.processing_started_at IS NULL OR webhook_logs.processing_started_at < NOW() - INTERVAL '5 minutes')
  RETURNING id INTO v_claimed;
  RETURN v_claimed IS NOT NULL;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.claim_razorpay_webhook(TEXT, TEXT, JSONB, BOOLEAN) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_razorpay_webhook(TEXT, TEXT, JSONB, BOOLEAN) TO service_role;
