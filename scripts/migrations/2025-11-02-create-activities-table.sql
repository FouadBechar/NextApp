-- Create activities table (simple schema). Adjust types/constraints to match your project conventions.
-- Create activities table (simple schema). Adjust types/constraints to match your project conventions.
CREATE TABLE IF NOT EXISTS activities (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text NULL,
  user_agent text NULL,
  ip text NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz NULL
);

-- Ensure optional columns exist for older deployments (safe to run multiple times)
ALTER TABLE activities ADD COLUMN IF NOT EXISTS user_agent text;
ALTER TABLE activities ADD COLUMN IF NOT EXISTS ip text;
ALTER TABLE activities ADD COLUMN IF NOT EXISTS updated_at timestamptz;

-- Optional index for querying by user
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities (user_id);
