-- Add nullable avatar_path column to profiles
-- Stores the storage path (e.g. avatars/<userId>/...); server will generate public/signed URLs as needed.

ALTER TABLE IF EXISTS public.profiles
  ADD COLUMN IF NOT EXISTS avatar_path text;

-- Note: we previously added avatar_url for quick migration; prefer avatar_path for long-term storage
-- If desired, you can migrate existing avatar_url values into avatar_path by parsing known public URL prefixes.

-- Optional index if you will query by avatar_path (uncommon):
-- CREATE INDEX IF NOT EXISTS idx_profiles_avatar_path ON public.profiles (avatar_path);
