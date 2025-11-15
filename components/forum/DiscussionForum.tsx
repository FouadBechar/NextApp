"use client";

import React, { useEffect, useState, useRef } from 'react';
import UserBadge from '@/components/forum/user-badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';

type Thread = {
  id: string;
  title: string;
  author_id?: string;
  author_display?: string | null;
  created_at?: string;
  reply_count?: number;
  content?: string;
};

type Post = {
  id: string;
  thread_id: string;
  content: string;
  author_id?: string;
  author_display?: string | null;
  created_at?: string;
};

export default function DiscussionForum(): React.ReactElement {
  const [threads, setThreads] = useState<Thread[]>([]);
  const [page, setPage] = useState(0);
  const pageSize = 10;
  const [selected, setSelected] = useState<Thread | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(false);
  const [creating, setCreating] = useState(false);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [replyBody, setReplyBody] = useState('');
  const mounted = useRef(true);

  useEffect(() => {
    mounted.current = true;
    fetchThreads();
    return () => {
      mounted.current = false;
    };
  }, []);

  async function fetchThreads() {
    setLoading(true);
    try {
      const res = await fetch('/api/forum/threads');
      if (!res.ok) throw new Error('Failed to load threads');
      const json = await res.json();
      if (mounted.current) setThreads(json.threads || []);
    } catch (err) {
      console.error(err);
    } finally {
      if (mounted.current) setLoading(false);
    }
  }

  async function openThread(thread: Thread) {
    setSelected(thread);
    setPosts([]);
    try {
      const res = await fetch(`/api/forum/threads/${thread.id}/posts`);
      if (!res.ok) throw new Error('Failed to load posts');
      const json = await res.json();
      setPosts(json.posts || []);
    } catch (err) {
      console.error(err);
    }
  }

  async function handleCreateThread(e?: React.FormEvent) {
    e?.preventDefault();
    if (!title.trim() || !body.trim()) return;
    setCreating(true);

    // optimistic thread
    const tempId = `temp-${Date.now()}`;
    const tempThread: Thread = {
      id: tempId,
      title: title.trim(),
      content: body.trim(),
      author_display: 'You',
      created_at: new Date().toISOString(),
      reply_count: 0,
    };
    setThreads((t) => [tempThread, ...t]);
    setSelected(tempThread);
    setPosts([]);

    try {
      const res = await fetch('/api/forum/threads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title.trim(), content: body.trim() }),
      });
      if (!res.ok) throw new Error('Failed to create thread');
      const json = await res.json();
      // replace temp with real
      setThreads((t) => t.map((th) => (th.id === tempId ? json.thread : th)));
      setTitle('');
      setBody('');
      setSelected(json.thread);
      openThread(json.thread);
    } catch (err) {
      // rollback optimistic
      setThreads((t) => t.filter((th) => th.id !== tempId));
      console.error(err);
    } finally {
      setCreating(false);
    }
  }

  async function handleReply(e?: React.FormEvent) {
    e?.preventDefault();
    if (!selected || !replyBody.trim()) return;
    // optimistic post
    const tempPost: Post = {
      id: `temp-${Date.now()}`,
      thread_id: selected.id,
      content: replyBody.trim(),
      author_display: 'You',
      created_at: new Date().toISOString(),
    };
    setPosts((p) => [...p, tempPost]);
    setReplyBody('');
    setThreads((t) => t.map((th) => (th.id === selected.id ? { ...th, reply_count: (th.reply_count || 0) + 1 } : th)));

    try {
      const res = await fetch(`/api/forum/threads/${selected.id}/posts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content: tempPost.content }),
      });
      if (!res.ok) throw new Error('Failed to post reply');
      const json = await res.json();
      // replace temp post with real post
      setPosts((p) => p.map((pt) => (pt.id === tempPost.id ? json.post : pt)));
    } catch (err) {
      // rollback optimistic
      setPosts((p) => p.filter((pt) => pt.id !== tempPost.id));
      setThreads((t) => t.map((th) => (th.id === selected.id ? { ...th, reply_count: Math.max(0, (th.reply_count || 1) - 1) } : th)));
      console.error(err);
    }
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>Community Discussion</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="mb-4">
                <form onSubmit={handleCreateThread} className="space-y-2">
                  <Input placeholder="Thread title" value={title} onChange={(e) => setTitle(e.target.value)} />
                  <textarea
                    placeholder="Start a discussion..."
                    value={body}
                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setBody(e.target.value)}
                    rows={4}
                    className="border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
                  />
                  <div className="flex gap-2 justify-end">
                    <Button type="submit" disabled={creating}>{creating ? 'Posting…' : 'Start Thread'}</Button>
                  </div>
                </form>
              </div>

              <div className="space-y-3">
                {loading ? (
                  <div className="text-center py-6">Loading threads…</div>
                ) : threads.length ? (
                  // pagination
                  threads.slice(page * pageSize, (page + 1) * pageSize).map((t) => (
                    <article
                      key={t.id}
                      className={`p-4 border rounded-md hover:shadow cursor-pointer ${selected?.id === t.id ? 'bg-muted' : ''}`}
                      onClick={() => openThread(t)}
                      role="button"
                    >
                      <h3 className="font-semibold">{t.title}</h3>
                      <div className="text-sm text-muted-foreground mt-1 flex items-center gap-2">
                        <UserBadge displayName={t.author_display} userId={t.author_id} size="sm" />
                        <span className="text-sm text-muted-foreground">{t.created_at ? new Date(t.created_at).toLocaleString() : ''}</span>
                      </div>
                      <div className="text-sm text-muted-foreground mt-2">{t.content ? (t.content.length > 180 ? t.content.slice(0, 180) + '…' : t.content) : ''}</div>
                      <div className="mt-2 text-xs text-muted-foreground">{(t.reply_count || 0)} replies</div>
                    </article>
                  ))
                ) : (
                  <div className="text-center py-8 text-muted-foreground">No discussions yet — be the first to start one.</div>
                )}
              </div>
              {/* pagination controls */}
              {threads.length > pageSize && (
                <div className="flex items-center justify-between mt-4">
                  <div className="text-sm text-muted-foreground">Page {page + 1} of {Math.max(1, Math.ceil(threads.length / pageSize))}</div>
                  <div className="flex gap-2">
                    <Button variant="ghost" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>Prev</Button>
                    <Button variant="ghost" onClick={() => setPage((p) => Math.min(Math.max(0, Math.ceil(threads.length / pageSize) - 1), p + 1))} disabled={(page + 1) * pageSize >= threads.length}>Next</Button>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        <aside>
          <Card>
            <CardHeader>
              <CardTitle>Quick Stats</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <div className="text-sm text-muted-foreground">Discussions</div>
                  <div className="font-medium">{threads.length}</div>
                </div>
                <div className="flex items-center justify-between">
                  <div className="text-sm text-muted-foreground">Active Thread</div>
                  <div className="font-medium">{selected?.title ? selected.title : '—'}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </aside>
      </div>

      {selected && (
        <Card>
          <CardHeader>
            <CardTitle>{selected.title}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="prose max-w-none mb-4">{selected.content}</div>
            <div className="space-y-4">
              {posts.length ? (
                posts.map((p) => (
                  <div key={p.id} className="p-3 border rounded">
                    <div className="text-sm text-muted-foreground flex items-center gap-2">
                      <UserBadge displayName={p.author_display} userId={p.author_id} size="sm" />
                      <span>{p.created_at ? new Date(p.created_at).toLocaleString() : ''}</span>
                    </div>
                    <div className="mt-2">{p.content}</div>
                  </div>
                ))
              ) : (
                <div className="text-sm text-muted-foreground">No replies yet. Start the conversation.</div>
              )}

              <form onSubmit={handleReply} className="mt-4">
                <textarea
                  placeholder="Write a reply…"
                  value={replyBody}
                  onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setReplyBody(e.target.value)}
                  rows={3}
                  className="border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
                />
                <div className="flex justify-end mt-2">
                  <Button type="submit">Reply</Button>
                </div>
              </form>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
