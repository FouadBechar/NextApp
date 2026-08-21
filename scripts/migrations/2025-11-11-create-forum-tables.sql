-- Create basic forum tables for threads and posts (Postgres / Supabase)
-- Run this in your Supabase SQL editor or with psql against your DB.

CREATE TABLE IF NOT EXISTS forum_threads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text,
  author_id uuid,
  author_display text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS forum_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL REFERENCES forum_threads(id) ON DELETE CASCADE,
  content text NOT NULL,
  author_id uuid,
  author_display text,
  created_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_forum_threads_created_at ON forum_threads (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_forum_posts_thread_id ON forum_posts (thread_id);
