
-- =========================================================================
-- 1. Create Storage Buckets
-- =========================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  (
    'categories',
    'categories',
    true,
    2097152, -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
  ),
  (
    'brands',
    'brands',
    true,
    2097152, -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
  )
ON CONFLICT (id) DO NOTHING;

-- =========================================================================
-- 2. Storage Security Policies (RLS)
-- =========================================================================

-- Categories bucket policies
DROP POLICY IF EXISTS "Public category images access" ON storage.objects;
DROP POLICY IF EXISTS "Admins manage category images" ON storage.objects;

CREATE POLICY "Public category images access" ON storage.objects
  FOR SELECT USING (bucket_id = 'categories');

CREATE POLICY "Admins manage category images" ON storage.objects
  FOR ALL
  USING (
    bucket_id = 'categories'
    AND public.is_admin()
    AND NOT public.is_current_user_suspended()
  )
  WITH CHECK (
    bucket_id = 'categories'
    AND public.is_admin()
    AND NOT public.is_current_user_suspended()
  );

-- Brands bucket policies
DROP POLICY IF EXISTS "Public brand images access" ON storage.objects;
DROP POLICY IF EXISTS "Admins manage brand images" ON storage.objects;

CREATE POLICY "Public brand images access" ON storage.objects
  FOR SELECT USING (bucket_id = 'brands');

CREATE POLICY "Admins manage brand images" ON storage.objects
  FOR ALL
  USING (
    bucket_id = 'brands'
    AND public.is_admin()
    AND NOT public.is_current_user_suspended()
  )
  WITH CHECK (
    bucket_id = 'brands'
    AND public.is_admin()
    AND NOT public.is_current_user_suspended()
  );