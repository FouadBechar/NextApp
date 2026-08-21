export type Thread = {
  id: string;
  title: string;
  author_id?: string;
  author_display?: string | null;
  author_avatar_url?: string | null;
  author_username?: string | null;
  pinned?: boolean;
  created_at?: string;
  reply_count?: number;
  content?: string;
};

export type Post = {
  id: string;
  thread_id: string;
  content: string;
  author_id?: string;
  author_display?: string | null;
  author_avatar_url?: string | null;
  pinned?: boolean;
  created_at?: string;
};
