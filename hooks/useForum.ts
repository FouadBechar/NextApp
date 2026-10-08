import { useEffect, useRef, useState } from "react";
import { toast } from "sonner";
import type { Thread, Post } from "@/types/forum";
import {
  getThreads,
  getThreadPosts,
  createForumThread,
  deleteForumThread,
  editForumThread,
  reportForumThread,
  pinForumThread,
  createPost,
  deletePost,
  editPost,
  reportPost,
  pinPost,
} from "@/lib/forum";

// Profile type is defined elsewhere in the app; assume globally available

type UserProfile = {
  id: string;
  username?: string | null;
  avatar_url?: string | null;
};

export function useForum() {
  const [threads, setThreads] = useState<Thread[]>([]);
  const [selected, setSelected] = useState<Thread | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingPosts, setLoadingPosts] = useState(false);
  const [loadingCurrentUser, setLoadingCurrentUser] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const activeThreadControllerRef = useRef<AbortController | null>(null);
  const mounted = useRef(true);

  useEffect(() => {
    mounted.current = true;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const threadsData = await getThreads();
        if (mounted.current) setThreads(threadsData);
      } catch (err) {
        if (mounted.current) setError("Failed to load discussions.");
        console.error(err);
      } finally {
        if (mounted.current) setLoading(false);
      }
    })();

    (async () => {
      if (mounted.current) setLoadingCurrentUser(true);
      try {
        const p = await fetch("/api/dashboard/profile");
        if (!p.ok) return;
        const pj = await p.json();
        if (mounted.current) setCurrentUser(pj.profile ?? null);
      } catch (_err) {
        // ignore
      } finally {
        if (mounted.current) setLoadingCurrentUser(false);
      }
    })();

    return () => {
      mounted.current = false;
      try {
        if (activeThreadControllerRef.current) {
          activeThreadControllerRef.current.abort();
          activeThreadControllerRef.current = null;
        }
      } catch {}
    };
  }, []);

  // listen for profile updates from other tabs or UI; update threads/posts/selected
  useEffect(() => {
    function handleProfileUpdate(e: any) {
      try {
        const detail = e?.detail || e?.data || null;
        if (!detail) return;
        const updatedUserId = detail.userId;
        const newUsername = detail.username ?? null;
        const newAvatarUrl = detail.avatar_url ?? detail.avatar ?? null;
        if (!updatedUserId) return;

        setThreads((prev) =>
          prev.map((t) =>
            t.author_id === updatedUserId
              ? {
                  ...t,
                  author_display: newUsername || t.author_display,
                  author_username: newUsername ?? t.author_username,
                  ...(newAvatarUrl !== null
                    ? { author_avatar_url: newAvatarUrl }
                    : {}),
                }
              : t
          )
        );
        setPosts((prev) =>
          prev.map((p) =>
            p.author_id === updatedUserId
              ? {
                  ...p,
                  author_display: newUsername || p.author_display,
                  ...(newAvatarUrl !== null
                    ? { author_avatar_url: newAvatarUrl }
                    : {}),
                }
              : p
          )
        );
        setSelected((prev) =>
          prev && prev.author_id === updatedUserId
            ? {
                ...prev,
                author_display: newUsername || prev.author_display,
                ...(newAvatarUrl !== null
                  ? { author_avatar_url: newAvatarUrl }
                  : {}),
              }
            : prev
        );
        setCurrentUser((prev) => {
          if (prev && prev.id === updatedUserId) {
            return {
              ...prev,
              username: newUsername ?? prev.username,
              ...(newAvatarUrl !== null ? { avatar_url: newAvatarUrl } : {}),
            };
          }
          return prev;
        });
      } catch (err) {
        // ignore
      }
    }

    let bc: BroadcastChannel | null = null;
    try {
      if (typeof window !== "undefined" && "BroadcastChannel" in window) {
        // @ts-ignore
        bc = new BroadcastChannel("profile-updates");
        bc.onmessage = (ev: MessageEvent) => handleProfileUpdate(ev);
      }
    } catch (e) {
      bc = null;
    }

    window.addEventListener("profile:updated", handleProfileUpdate as EventListener);
    return () => {
      try {
        window.removeEventListener("profile:updated", handleProfileUpdate as EventListener);
      } catch (e) {}
      try {
        if (bc) {
          bc.close();
          bc = null;
        }
      } catch (e) {}
    };
  }, []);

  async function openThread(thread: Thread) {
    setSelected(thread);
    setPosts([]);
    try {
      if (activeThreadControllerRef.current) {
        activeThreadControllerRef.current.abort();
        activeThreadControllerRef.current = null;
      }
    } catch {}

    const controller = new AbortController();
    activeThreadControllerRef.current = controller;
    setLoadingPosts(true);
    setError(null);
    try {
      const postsData = await getThreadPosts(thread.id, 200, controller.signal);
      if (controller.signal.aborted) return;
      setPosts(postsData);
    } catch (err: any) {
      if (err?.name === "AbortError") return;
      if (mounted.current) setError("Failed to load replies.");
      console.error(err);
    } finally {
      if (activeThreadControllerRef.current === controller) {
        activeThreadControllerRef.current = null;
        setLoadingPosts(false);
      }
    }
  }

  async function createThread(title: string, content: string) {
    if (!title.trim() || !content.trim()) return;
    setLoading(true);
    setError(null);

    // optimistic
    const tempId = `temp-${Date.now()}`;
    const tempThread: Thread = {
      id: tempId,
      title: title.trim(),
      content: content.trim(),
      author_display: currentUser?.username ?? "You",
      author_id: currentUser?.id ?? undefined,
      author_avatar_url: currentUser?.avatar_url ?? null,
      created_at: new Date().toISOString(),
      reply_count: 0,
    };
    setThreads((t) => [tempThread, ...t]);
    setSelected(tempThread);
    setPosts([]);

    try {
      const json = await createForumThread(title.trim(), content.trim());
      setThreads((t) =>
        t.map((th) => (th.id === tempId ? json.thread : th))
      );
      setSelected(json.thread);
      openThread(json.thread);
    } catch (err) {
      setThreads((t) => t.filter((th) => th.id !== tempId));
      setError("Failed to create discussion.");
      console.error(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }

  async function reply(threadId: string, content: string) {
    if (!threadId || !content.trim()) return;
    if (String(threadId).startsWith("temp-")) {
      toast.error("Thread is being created — please wait a moment and try again.");
      return;
    }
    setError(null);

    // optimistic
    const tempPost: Post = {
      id: `temp-${Date.now()}`,
      thread_id: threadId,
      content: content.trim(),
      author_display: currentUser?.username ?? "You",
      author_id: currentUser?.id ?? undefined,
      author_avatar_url: currentUser?.avatar_url ?? null,
      created_at: new Date().toISOString(),
    };
    setPosts((p) => [...p, tempPost]);
    setThreads((t) =>
      t.map((th) =>
        th.id === threadId
          ? { ...th, reply_count: (th.reply_count || 0) + 1 }
          : th
      )
    );

    try {
      const json = await createPost(threadId, tempPost.content);
      setPosts((p) =>
        p.map((pt) => (pt.id === tempPost.id ? json.post : pt))
      );
    } catch (err) {
      setPosts((p) => p.filter((pt) => pt.id !== tempPost.id));
      setThreads((t) =>
        t.map((th) =>
          th.id === threadId
            ? { ...th, reply_count: Math.max(0, (th.reply_count || 1) - 1) }
            : th
        )
      );
      toast.error("Failed to post reply — please try again");
      setError("Failed to post reply.");
      console.error(err);
      throw err;
    }
  }

  async function deleteThread(threadId: string) {
    if (!threadId) return;
    const prev = [...threads];
    setThreads((t) => t.filter((x) => x.id !== threadId));
    if (selected?.id === threadId) {
      setSelected(null);
      setPosts([]);
    }
    try {
      await deleteForumThread(threadId);
      toast.success("Thread deleted");
    } catch (err) {
      setThreads(prev);
      toast.error("Failed to delete thread");
      setError("Failed to delete discussion.");
      console.error(err);
      throw err;
    }
  }

  async function deleteReply(threadId: string, postId: string) {
    if (!threadId || !postId) return;
    const prevPosts = [...posts];
    const prevThreads = [...threads];
    setPosts((p) => p.filter((x) => x.id !== postId));
    setThreads((t) =>
      t.map((th) =>
        th.id === threadId
          ? { ...th, reply_count: Math.max(0, (th.reply_count || 1) - 1) }
          : th
      )
    );
    try {
      await deletePost(threadId, postId);
      toast.success("Reply deleted");
    } catch (err) {
      setPosts(prevPosts);
      setThreads(prevThreads);
      toast.error("Failed to delete reply");
      setError("Failed to delete reply.");
      console.error(err);
      throw err;
    }
  }

  async function editThread(threadId: string, updated: { title?: string; content?: string }) {
    if (!threadId) return;
    const prev = [...threads];
    const prevSelected = selected;
    setThreads((t) =>
      t.map((th) =>
        th.id === threadId
          ? { ...th, title: updated.title ?? th.title, content: updated.content ?? th.content }
          : th
      )
    );
    setSelected((prevThread) =>
      prevThread && prevThread.id === threadId
        ? {
            ...prevThread,
            title: updated.title ?? prevThread.title,
            content: updated.content ?? prevThread.content,
          }
        : prevThread
    );
    try {
      await editForumThread(threadId, updated);
      toast.success("Thread updated");
    } catch (err) {
      setThreads(prev);
      setSelected(prevSelected);
      toast.error("Failed to update thread");
      setError("Failed to update discussion.");
      console.error(err);
      throw err;
    }
  }

  async function editReply(threadId: string, postId: string, updated: { content?: string }) {
    if (!threadId || !postId) return;
    const prev = [...posts];
    setPosts((p) =>
      p.map((pt) => (pt.id === postId ? { ...pt, content: updated.content ?? pt.content } : pt))
    );
    try {
      await editPost(threadId, postId, updated);
      toast.success("Reply updated");
    } catch (err) {
      setPosts(prev);
      toast.error("Failed to update reply");
      setError("Failed to update reply.");
      console.error(err);
      throw err;
    }
  }

  async function reportThread(threadId: string) {
    try {
      await reportForumThread(threadId);
      toast.success("Reported — thank you");
    } catch (err) {
      toast.error("Failed to report thread — please try again");
      setError("Failed to report discussion.");
      console.error(err);
      throw err;
    }
  }

  async function reportReply(threadId: string, postId: string) {
    try {
      await reportPost(threadId, postId);
      toast.success("Reported — thank you");
    } catch (err) {
      toast.error("Failed to report reply — please try again");
      setError("Failed to report reply.");
      console.error(err);
      throw err;
    }
  }

  async function togglePinThread(threadId: string) {
    const previousThread = threads.find((thread) => thread.id === threadId);
    if (!previousThread) return;
    setThreads((prev) =>
      prev.map((th) => (th.id === threadId ? { ...th, pinned: !th.pinned } : th))
    );
    setSelected((prev) =>
      prev?.id === threadId ? { ...prev, pinned: !prev.pinned } : prev
    );
    try {
      await pinForumThread(threadId);
    } catch (err) {
      setThreads((prev) =>
        prev.map((thread) =>
          thread.id === threadId
            ? { ...thread, pinned: previousThread.pinned }
            : thread
        )
      );
      setSelected((prev) =>
        prev?.id === threadId
          ? { ...prev, pinned: previousThread.pinned }
          : prev
      );
      toast.error("Failed to update thread pin");
      setError("Failed to update thread pin.");
      console.error(err);
      throw err;
    }
  }

  async function togglePinReply(post: Post) {
    setPosts((prev) =>
      prev.map((pt) => (pt.id === post.id ? { ...pt, pinned: !pt.pinned } : pt))
    );
    try {
      await pinPost(post.thread_id, post.id);
    } catch (err) {
      setPosts((prev) =>
        prev.map((reply) =>
          reply.id === post.id ? { ...reply, pinned: post.pinned } : reply
        )
      );
      toast.error("Failed to update reply pin");
      setError("Failed to update reply pin.");
      console.error(err);
      throw err;
    }
  }

  return {
    threads,
    selected,
    posts,
    loading,
    loadingPosts,
    loadingCurrentUser,
    error,
    clearError: () => setError(null),
    currentUser,
    openThread,
    createThread,
    reply,
    deleteThread,
    deleteReply,
    editThread,
    editReply,
    reportThread,
    reportReply,
    togglePinThread,
    togglePinReply,
    setSelected, // expose for outside if needed
  };
}
