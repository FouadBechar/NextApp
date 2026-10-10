-- Add nullable avatar_url column to profiles
-- Safe, non-destructive migration: adds a TEXT column and leaves existing rows unchanged.

ALTER TABLE IF EXISTS public.profiles
  ADD COLUMN IF NOT EXISTS avatar_url text;

-- Optional: if you prefer a length limit, replace the above with varchar(2048) instead of text.
-- ALTER TABLE IF EXISTS public.profiles
--   ADD COLUMN IF NOT EXISTS avatar_url varchar(2048);

-- Optional index: usually not necessary unless you plan to filter/search by avatar_url
-- CREATE INDEX IF NOT EXISTS idx_profiles_avatar_url ON public.profiles (avatar_url);

-- Notes:
-- 1) This stores the public URL (or path) to the avatar. If you prefer storing only the storage path
--    (e.g. avatars/<userId>/...) use `avatar_path` instead and keep URL-generation server-side.
-- 2) After running this migration, the profile update API can persist `avatar_url` safely.
