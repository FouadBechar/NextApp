-- Migration: add author_avatar_url to forum tables
-- Adds a denormalized column for storing resolved avatar URLs for faster reads

ALTER TABLE IF EXISTS public.forum_threads
  ADD COLUMN IF NOT EXISTS author_avatar_url text NULL;

ALTER TABLE IF EXISTS public.forum_posts
  ADD COLUMN IF NOT EXISTS author_avatar_url text NULL;

-- Optional indexes for faster lookups by author
CREATE INDEX IF NOT EXISTS idx_forum_threads_author_id ON public.forum_threads (author_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_author_id ON public.forum_posts (author_id);
