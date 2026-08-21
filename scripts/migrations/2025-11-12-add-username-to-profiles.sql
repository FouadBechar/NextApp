-- Add username column to profiles and create a unique index to enforce uniqueness
-- Intended for Postgres / Supabase SQL editor

ALTER TABLE IF EXISTS profiles
  ADD COLUMN IF NOT EXISTS username text;

-- Create a unique index to enforce case-sensitive uniqueness
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username ON profiles (username);

-- If you prefer case-insensitive uniqueness, use the following instead:
-- CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username_ci ON profiles (lower(username));
