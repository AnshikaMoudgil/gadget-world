-- Reliable profile-avatar storage and access controls.
-- Safe to apply to databases where the original avatar migration was fully,
-- partially, or not yet applied.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public;

DROP POLICY IF EXISTS "Avatar images are publicly accessible."
  ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar."
  ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar."
  ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar."
  ON storage.objects;

-- Avatars are public because the application stores their public URLs in the
-- profile. Upload/update/delete remain restricted to the owning user's folder.
CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar."
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );

CREATE POLICY "Users can update their own avatar."
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );

CREATE POLICY "Users can delete their own avatar."
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );
