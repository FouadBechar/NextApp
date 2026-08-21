-- Migration: create notifications_sent table to track broadcast email activity
CREATE TABLE IF NOT EXISTS public.notifications_sent (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject text,
  body text,
  sent_by text,
  recipients_count integer DEFAULT 0,
  sent_count integer DEFAULT 0,
  failed_count integer DEFAULT 0,
  dry_run boolean DEFAULT false,
  meta jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_sent_sent_by ON public.notifications_sent (sent_by);
CREATE INDEX IF NOT EXISTS idx_notifications_sent_created_at ON public.notifications_sent (created_at);
