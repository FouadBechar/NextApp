"use client";

import React, { useEffect, useRef, useState } from "react";
import { useTyping } from "@/components/typing/TypingProvider";
import { useInputFocusPersistence } from "@/hooks/useInputFocusPersistence";
import { useForum } from "@/hooks/useForum";
import type { Thread, Post } from "@/types/forum";
import ThreadList from "@/components/forum/ThreadList";
import QuickStats from "@/components/forum/QuickStats";
import Modal from "@/components/ui/modal";
import ReplyForm from "@/components/forum/ReplyForm";
import PostItem from "@/components/forum/PostItem";
import UserBadge from "@/components/forum/user-badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";


export default function DiscussionForum(): React.ReactElement {
  const {
    threads,
    selected,
    posts,
    loading,
    loadingPosts,
    loadingCurrentUser,
    error: forumError,
    clearError,
    currentUser,
    openThread,
    createThread: createThreadFn,
    reply: replyFn,
    deleteThread: deleteThreadFn,
    deleteReply: deleteReplyFn,
    editThread: editThreadFn,
    editReply: editReplyFn,
    reportThread: reportThreadFn,
    reportReply: reportReplyFn,
    togglePinThread: togglePinThreadFn,
    togglePinReply: togglePinReplyFn,
  } = useForum();

  const [creating, setCreating] = useState(false);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [replyBody, setReplyBody] = useState("");
  const [replyComposerOpen, setReplyComposerOpen] = useState(false);
  const [posting, setPosting] = useState(false);
  const selectedThreadRef = useRef<HTMLDivElement | null>(null);

  // track focused input & caret using a shared hook so we can restore focus
  // when the thread list updates
  const { createHandlers } = useInputFocusPersistence(
    {
      title: "create-thread-title",
      body: "create-thread-body",
      reply: "reply-body",
      editThreadTitle: "edit-thread-title",
      editThreadContent: "edit-thread-content",
      editPost: "edit-post-content",
    },
    [threads],
    {
      onFocus: () => {
        try {
          setIsTyping(true);
        } catch (err) {}
      },
      onBlur: () => {
        try {
          setIsTyping(false);
        } catch (err) {}
      },
    }
  );
  // menu is handled by Menu component (no local open id needed)
  const [confirmDeleteThreadId, setConfirmDeleteThreadId] = useState<
    string | null
  >(null);
  const [confirmDeletePost, setConfirmDeletePost] = useState<{
    threadId: string;
    postId: string;
  } | null>(null);
  const [editingThread, setEditingThread] = useState<Thread | null>(null);
  const [editingPost, setEditingPost] = useState<Post | null>(null);

  useEffect(() => {
    if (editingThread) {
      setEditTitle(editingThread.title ?? "");
      setEditContent(editingThread.content ?? "");
    } else {
      setEditTitle("");
      setEditContent("");
    }
  }, [editingThread]);

  useEffect(() => {
    if (editingPost) {
      setEditPostContent(editingPost.content ?? "");
    } else {
      setEditPostContent("");
    }
  }, [editingPost]);

  useEffect(() => {
    setReplyBody("");
    setReplyComposerOpen(false);
  }, [selected?.id]);

  useEffect(() => {
    if (!selected?.id) return;

    const isMobile = window.matchMedia("(max-width: 1023px)").matches;
    if (!isMobile) return;

    window.setTimeout(() => {
      selectedThreadRef.current?.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }, 120);
  }, [selected?.id]);
  const [reportingThreadId, setReportingThreadId] = useState<string | null>(
    null
  );
  const [reportingPost, setReportingPost] = useState<{
    threadId: string;
    postId: string;
  } | null>(null);

  // Edit modal controlled inputs
  const [editTitle, setEditTitle] = useState("");
  const [editContent, setEditContent] = useState("");
  const [editPostContent, setEditPostContent] = useState("");

  // all forum state and network effects are handled by useForum hook

  // Typing context: when input focus is gained/lost, update global typing state
  const { setIsTyping } = useTyping();

  // Close inline kebab menu when clicking outside
  // The Menu component manages focus and closing behavior.

  // Menu components manage focus and Escape handling themselves.

  // Listen for profile updates (from profile page) and update in-memory state.

  // Delete a thread (only allowed for author or authorized users).
  async function handleDeleteThread(threadId: string) {
    if (!threadId) return;
    try {
      await deleteThreadFn(threadId);
    } catch (err) {
      console.error(err);
    }
  }

  // Delete a post/reply
  async function handleDeletePost(threadId: string, postId: string) {
    if (!threadId || !postId) return;
    try {
      await deleteReplyFn(threadId, postId);
    } catch (err) {
      console.error(err);
    }
  }

  async function handleEditThreadSave(
    threadId: string,
    updated: { title?: string; content?: string }
  ) {
    if (!threadId) return;
    try {
      await editThreadFn(threadId, updated);
      setEditingThread(null);
    } catch (err) {
      console.error(err);
    }
  }

  async function handleEditPostSave(
    threadId: string,
    postId: string,
    updated: { content?: string }
  ) {
    if (!threadId || !postId) return;
    try {
      await editReplyFn(threadId, postId, updated);
      setEditingPost(null);
    } catch (err) {
      console.error(err);
    }
  }

  async function handleReportThread(threadId: string) {
    setReportingThreadId(null);
    await reportThreadFn(threadId);
  }

  async function handleReportPost(threadId: string, postId: string) {
    setReportingPost(null);
    await reportReplyFn(threadId, postId);
  }

  async function handleCreateThread(e?: React.FormEvent) {
    e?.preventDefault();
    if (!title.trim() || !body.trim()) return;
    setCreating(true);
    try {
      await createThreadFn(title.trim(), body.trim());
      setTitle("");
      setBody("");
    } catch (err) {
      // error handled in hook
      console.error(err);
    } finally {
      setCreating(false);
    }
  }

  async function handleReply(e?: React.FormEvent) {
    e?.preventDefault();
    if (!selected || !replyBody.trim()) return;
    setPosting(true);
    try {
      await replyFn(selected.id, replyBody.trim());
      setReplyBody("");
      setReplyComposerOpen(false);
    } catch (err) {
      console.error(err);
    } finally {
      setPosting(false);
    }
  }

  return (
    <div className="space-y-6">
      {forumError && (
        <Alert variant="destructive">
          <AlertDescription className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <span>{forumError}</span>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={clearError}
              className="self-start sm:self-auto"
            >
              Dismiss
            </Button>
          </AlertDescription>
        </Alert>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>Community Discussion</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="mb-4">
                <form onSubmit={handleCreateThread} className="space-y-2">
                  <Input
                    placeholder="Thread title"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    onKeyDown={(e) => e.stopPropagation()}
                    {...createHandlers("title")}
                  />
                  <textarea
                    placeholder="Start a discussion..."
                    value={body}
                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) =>
                      setBody(e.target.value)
                    }
                    onKeyDown={(e) => e.stopPropagation()}
                    {...createHandlers("body")}
                    rows={4}
                    className="border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
                  />
                  <div className="flex gap-2 justify-end">
                    <Button type="submit" disabled={creating}>
                      {creating ? "Posting…" : "Start Thread"}
                    </Button>
                  </div>
                </form>
              </div>

              <div className="space-y-3">
                {loading ? (
                  <div className="text-center py-6">Loading threads…</div>
                ) : (
                  <ThreadList
                    threads={threads}
                    currentUserId={currentUser?.id ?? null}
                    selectedId={selected?.id ?? null}
                    onSelect={openThread}
                    onEdit={(t) => setEditingThread(t)}
                    onRequestDelete={(id) => setConfirmDeleteThreadId(id)}
                    onRequestReport={(id) => setReportingThreadId(id)}
                    onTogglePin={(id) => {
                      togglePinThreadFn(id);
                    }}
                  />
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        <aside>
          <QuickStats threadsCount={threads.length} activeTitle={selected?.title ?? null} />
        </aside>
      </div>

      {selected ? (
        <Card ref={selectedThreadRef}>
          <CardHeader>
            <div className="space-y-3">
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-2">
                  <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                    Selected discussion
                  </div>
                  <CardTitle>{selected.title}</CardTitle>
                </div>
                {selected.pinned ? (
                  <span className="rounded bg-primary px-2 py-0.5 text-xs text-primary-foreground">
                    Pinned
                  </span>
                ) : null}
              </div>
              <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-muted-foreground">
                <UserBadge
                  username={selected.author_display ?? selected.author_username ?? null}
                  avatarUrl={selected.author_avatar_url ?? null}
                  userId={selected.author_id ?? null}
                  showProfileLink={false}
                />
                <span>
                  {selected.created_at
                    ? new Date(selected.created_at).toLocaleString()
                    : "Just now"}
                </span>
                <span>
                  {selected.reply_count || 0} {(selected.reply_count || 0) === 1 ? "reply" : "replies"}
                </span>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="prose max-w-none mb-4">{selected.content}</div>
            <div className="space-y-4">
              {!loadingPosts && (
                <div className="border-t pt-4">
                  <ReplyForm
                    value={replyBody}
                    onChange={(v) => setReplyBody(v)}
                    onSubmit={handleReply}
                    onExpand={() => setReplyComposerOpen(true)}
                    onCancel={() => {
                      setReplyBody("");
                      setReplyComposerOpen(false);
                    }}
                    isExpanded={replyComposerOpen}
                    currentUser={currentUser}
                    currentUserLoading={loadingCurrentUser}
                    posting={posting}
                    maxLength={5000}
                    {...createHandlers("reply")}
                  />
                </div>
              )}

              {loadingPosts ? (
                <div className="flex flex-col items-center py-6">
                  <div className="animate-spin rounded-full h-6 w-6 border-t-2 border-b-2 border-primary mb-2" />
                  <div className="text-sm text-muted-foreground">Loading replies…</div>
                </div>
              ) : posts.length ? (
                <div role="log" aria-live="polite" aria-atomic="true" className="space-y-3">
                  {posts.map((p) => (
                    <PostItem
                      key={p.id}
                      post={p}
                      currentUserId={currentUser?.id ?? null}
                      onEdit={(post) => setEditingPost(post)}
                      onDelete={(threadId, postId) =>
                        setConfirmDeletePost({ threadId, postId })
                      }
                      onReport={(payload) => setReportingPost(payload)}
                      togglePin={(post) => {
                        togglePinReplyFn(post);
                      }}
                    />
                  ))}
                </div>
              ) : (
                <div className="text-sm text-muted-foreground">
                  No replies yet. Start the conversation.
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="py-10">
            <div className="mx-auto max-w-md text-center">
              <div className="text-lg font-semibold">Select a discussion</div>
              <p className="mt-2 text-sm text-muted-foreground">
                Choose a thread from the list to read replies, join the conversation, or review the latest activity.
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Confirm Delete Thread modal */}
      <Modal
        open={!!confirmDeleteThreadId}
        onClose={() => setConfirmDeleteThreadId(null)}
        ariaLabel="Confirm Delete Thread"
      >
        <div className="space-y-4">
          <div className="text-lg font-semibold">Delete this thread?</div>
          <div className="text-sm text-muted-foreground">
            This action will remove the thread and all associated replies. This
            cannot be undone.
          </div>
          <div className="flex gap-2 justify-end pt-2">
            <Button
              variant="ghost"
              onClick={() => setConfirmDeleteThreadId(null)}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => {
                if (confirmDeleteThreadId)
                  handleDeleteThread(confirmDeleteThreadId);
                setConfirmDeleteThreadId(null);
              }}
            >
              Delete
            </Button>
          </div>
        </div>
      </Modal>

      {/* Confirm Delete Post modal */}
      <Modal
        open={!!confirmDeletePost}
        onClose={() => setConfirmDeletePost(null)}
        ariaLabel="Confirm Delete Reply"
      >
        <div className="space-y-4">
          <div className="text-lg font-semibold">Delete this reply?</div>
          <div className="text-sm text-muted-foreground">
            This action will remove the reply. This cannot be undone.
          </div>
          <div className="flex gap-2 justify-end pt-2">
            <Button variant="ghost" onClick={() => setConfirmDeletePost(null)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => {
                if (confirmDeletePost)
                  handleDeletePost(
                    confirmDeletePost.threadId,
                    confirmDeletePost.postId
                  );
                setConfirmDeletePost(null);
              }}
            >
              Delete
            </Button>
          </div>
        </div>
      </Modal>

      {/* Edit Thread modal */}
      <Modal
        open={!!editingThread}
        onClose={() => setEditingThread(null)}
        ariaLabel="Edit Thread"
      >
        {editingThread && (
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleEditThreadSave(editingThread.id, {
                title: editTitle,
                content: editContent,
              });
            }}
          >
            <div className="space-y-4">
              <div>
                <label
                  htmlFor="edit-thread-title"
                  className="block text-sm font-medium"
                >
                  Title
                </label>
                <input
                  placeholder="Thread title"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  className="mt-1 block w-full rounded-md border-input px-3 py-2"
                  onKeyDown={(e) => e.stopPropagation()}
                  {...createHandlers("editThreadTitle")}
                />
              </div>
              <div>
                <label
                  htmlFor="edit-thread-content"
                  className="block text-sm font-medium"
                >
                  Content
                </label>
                <textarea
                  placeholder="Thread content"
                  value={editContent}
                  onChange={(e) => setEditContent(e.target.value)}
                  rows={5}
                  className="mt-1 block w-full rounded-md border-input px-3 py-2"
                  onKeyDown={(e) => e.stopPropagation()}
                  {...createHandlers("editThreadContent")}
                />
              </div>
              <div className="flex gap-2 justify-end pt-2">
                <Button
                  variant="ghost"
                  onClick={() => {
                    setEditingThread(null);
                  }}
                >
                  Cancel
                </Button>
                <Button type="submit">Save</Button>
              </div>
            </div>
          </form>
        )}
      </Modal>

      {/* Edit Post modal */}
      <Modal
        open={!!editingPost}
        onClose={() => setEditingPost(null)}
        ariaLabel="Edit Reply"
      >
        {editingPost && (
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleEditPostSave(editingPost.thread_id, editingPost.id, {
                content: editPostContent,
              });
            }}
          >
            <div className="space-y-4">
              <div>
                <label
                  htmlFor="edit-post-content"
                  className="block text-sm font-medium"
                >
                  Content
                </label>
                <textarea
                  placeholder="Reply content"
                  value={editPostContent}
                  onChange={(e) => setEditPostContent(e.target.value)}
                  rows={5}
                  className="mt-1 block w-full rounded-md border-input px-3 py-2"
                  onKeyDown={(e) => e.stopPropagation()}
                  {...createHandlers("editPost")}
                />
              </div>
              <div className="flex gap-2 justify-end pt-2">
                <Button variant="ghost" onClick={() => setEditingPost(null)}>
                  Cancel
                </Button>
                <Button type="submit">Save</Button>
              </div>
            </div>
          </form>
        )}
      </Modal>

      {/* Report Thread confirm */}
      <Modal
        open={!!reportingThreadId}
        onClose={() => setReportingThreadId(null)}
        ariaLabel="Report Thread"
      >
        <div className="space-y-4">
          <div className="text-lg font-semibold">Report this thread?</div>
          <div className="text-sm text-muted-foreground">
            Reporting helps moderators review content that may violate rules.
          </div>
          <div className="flex gap-2 justify-end pt-2">
            <Button variant="ghost" onClick={() => setReportingThreadId(null)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => {
                if (reportingThreadId) handleReportThread(reportingThreadId);
              }}
            >
              Report
            </Button>
          </div>
        </div>
      </Modal>

      {/* Report Post confirm */}
      <Modal
        open={!!reportingPost}
        onClose={() => setReportingPost(null)}
        ariaLabel="Report Reply"
      >
        <div className="space-y-4">
          <div className="text-lg font-semibold">Report this reply?</div>
          <div className="text-sm text-muted-foreground">
            Reporting helps moderators review content that may violate rules.
          </div>
          <div className="flex gap-2 justify-end pt-2">
            <Button variant="ghost" onClick={() => setReportingPost(null)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => {
                if (reportingPost)
                  handleReportPost(
                    reportingPost.threadId,
                    reportingPost.postId
                  );
              }}
            >
              Report
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
