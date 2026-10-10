-- Migration: add `pinned` boolean column to forum_threads/forum_posts
-- and create forum_reports table to record user reports of threads/posts.
--
-- Add columns for pinned flags to threads and posts
ALTER TABLE IF EXISTS public.forum_threads
  ADD COLUMN IF NOT EXISTS pinned boolean DEFAULT false;

ALTER TABLE IF EXISTS public.forum_posts
  ADD COLUMN IF NOT EXISTS pinned boolean DEFAULT false;

-- Create `forum_reports` table to store moderation reports
CREATE TABLE IF NOT EXISTS public.forum_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid REFERENCES public.profiles(id),
  target_type text NOT NULL CHECK (target_type IN ('thread', 'post')),
  thread_id uuid REFERENCES public.forum_threads(id) ON DELETE CASCADE,
  post_id uuid REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  reason text,
  created_at timestamptz DEFAULT now()
);

-- Indexes to speed up moderator queries and lookups
CREATE INDEX IF NOT EXISTS idx_forum_reports_thread_id ON public.forum_reports (thread_id);
CREATE INDEX IF NOT EXISTS idx_forum_reports_post_id ON public.forum_reports (post_id);
