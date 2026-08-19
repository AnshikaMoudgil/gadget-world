-- =========================================================================
-- SECTION 5: Storage Bucket for Product Images
-- =========================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'products',
  'products',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public product images access" ON storage.objects;
DROP POLICY IF EXISTS "Admins manage product images" ON storage.objects;

CREATE POLICY "Public product images access" ON storage.objects
  FOR SELECT USING (bucket_id = 'products');

CREATE POLICY "Admins manage product images" ON storage.objects
  FOR ALL
  USING (bucket_id = 'products' AND public.is_admin() AND NOT public.is_current_user_suspended())
  WITH CHECK (bucket_id = 'products' AND public.is_admin() AND NOT public.is_current_user_suspended());
