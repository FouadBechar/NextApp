-- Add a JSONB preferences column to profiles with a sensible default
ALTER TABLE IF EXISTS profiles
  ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}'::jsonb;

-- Create an index for quick querying if you filter/search inside the JSON
CREATE INDEX IF NOT EXISTS idx_profiles_preferences ON profiles USING gin (preferences);
