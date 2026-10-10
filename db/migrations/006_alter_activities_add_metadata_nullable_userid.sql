-- Migration: alter existing activities table to add metadata JSONB and make user_id nullable
ALTER TABLE IF EXISTS public.activities
  ADD COLUMN IF NOT EXISTS metadata jsonb,
  ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- Make user_id nullable so system activities can be stored without a user
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'activities' AND column_name = 'user_id'
  ) THEN
    -- Attempt to drop not null constraint (if any)
    BEGIN
      ALTER TABLE public.activities ALTER COLUMN user_id DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
      -- ignore errors (e.g., constraint already absent)
      RAISE NOTICE 'user_id nullability already altered or error occured';
    END;
  END IF;
END;
$$;

-- Create GIN index on metadata to support jsonb queries
CREATE INDEX IF NOT EXISTS idx_activities_metadata_gin ON public.activities USING gin (metadata);

-- Ensure there is an index for created_at for efficient ordering
CREATE INDEX IF NOT EXISTS idx_activities_created_at ON public.activities (created_at);
