-- Migration: sync profiles.avatar_url into forum denormalized columns
-- This creates a trigger that updates forum_threads.author_avatar_url and
-- forum_posts.author_avatar_url whenever profiles.avatar_url changes or is set.
--
-- Notes:
-- - For large numbers of posts the update can be expensive. Consider batching
--   this update using an async job or background worker if you expect heavy
--   workloads.
-- - This migration assumes the tables and indexes already exist:
--   - forum_threads.author_id
--   - forum_posts.author_id
--   - forum_threads.author_avatar_url
--   - forum_posts.author_avatar_url
--
-- Create or replace the function that performs the update on profile change
CREATE OR REPLACE FUNCTION public.sync_profile_avatar_url_to_forum()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- If this is an UPDATE and the avatar_url didn't change, do nothing.
  IF TG_OP = 'UPDATE' AND (OLD.avatar_url IS NOT DISTINCT FROM NEW.avatar_url) THEN
    RETURN NEW;
  END IF;

  -- Update denormalized columns on both forum tables. If NEW.avatar_url is
  -- null, clear the denormalized value.
  IF NEW.avatar_url IS NOT NULL THEN
    UPDATE public.forum_threads
      SET author_avatar_url = NEW.avatar_url
     WHERE author_id = NEW.id;

    UPDATE public.forum_posts
      SET author_avatar_url = NEW.avatar_url
     WHERE author_id = NEW.id;
  ELSE
    -- Clear the denormalized column when avatar becomes null
    UPDATE public.forum_threads
      SET author_avatar_url = NULL
     WHERE author_id = NEW.id;

    UPDATE public.forum_posts
      SET author_avatar_url = NULL
     WHERE author_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

-- Drop existing trigger if present (idempotent)
DROP TRIGGER IF EXISTS trg_profiles_sync_avatar_url ON public.profiles;

-- Create the trigger that fires after insert or update of avatar_url
CREATE TRIGGER trg_profiles_sync_avatar_url
AFTER INSERT OR UPDATE OF avatar_url ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sync_profile_avatar_url_to_forum();
