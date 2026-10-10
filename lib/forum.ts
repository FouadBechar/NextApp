import { Thread, Post } from "@/types/forum";

async function handleFetch<ResponseType>(input: RequestInfo, init?: RequestInit) {
  const res = await fetch(input, { credentials: "same-origin", ...init });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(text || res.statusText);
  }
  return res.json() as Promise<ResponseType>;
}

export async function getThreads(): Promise<Thread[]> {
  const json = await handleFetch<{ threads: Thread[] }>('/api/forum/threads');
  return json.threads || [];
}

export async function getThreadPosts(
  threadId: string,
  limit = 200,
  signal?: AbortSignal
): Promise<Post[]> {
  const json = await handleFetch<{ posts: Post[] }>(
    `/api/forum/threads/${threadId}/posts?limit=${limit}`,
    { signal }
  );
  return json.posts || [];
}

export async function createForumThread(
  title: string,
  content: string
): Promise<{ thread: Thread }> {
  return handleFetch<{ thread: Thread }>("/api/forum/threads", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title, content }),
  });
}

export async function deleteForumThread(threadId: string): Promise<void> {
  await handleFetch<void>(`/api/forum/threads/${threadId}`, {
    method: "DELETE",
  });
}

export async function editForumThread(
  threadId: string,
  updated: { title?: string; content?: string }
): Promise<void> {
  await handleFetch<void>(`/api/forum/threads/${threadId}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(updated),
  });
}

export async function reportForumThread(threadId: string): Promise<void> {
  await handleFetch<void>(`/api/forum/threads/${threadId}/report`, {
    method: "POST",
  });
}

export async function pinForumThread(threadId: string): Promise<void> {
  await handleFetch<void>(`/api/forum/threads/${threadId}/pin`, {
    method: "POST",
  });
}

// posts
export async function createPost(
  threadId: string,
  content: string
): Promise<{ post: Post }> {
  return handleFetch<{ post: Post }>(
    `/api/forum/threads/${threadId}/posts?limit=200`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ content }),
    }
  );
}

export async function deletePost(threadId: string, postId: string): Promise<void> {
  await handleFetch<void>(
    `/api/forum/threads/${threadId}/posts/${postId}`,
    { method: "DELETE" }
  );
}

export async function editPost(
  threadId: string,
  postId: string,
  updated: { content?: string }
): Promise<void> {
  await handleFetch<void>(
    `/api/forum/threads/${threadId}/posts/${postId}`,
    {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updated),
    }
  );
}

export async function reportPost(
  threadId: string,
  postId: string
): Promise<void> {
  await handleFetch<void>(
    `/api/forum/threads/${threadId}/posts/${postId}/report`,
    { method: "POST" }
  );
}

export async function pinPost(threadId: string, postId: string): Promise<void> {
  await handleFetch<void>(
    `/api/forum/threads/${threadId}/posts/${postId}/pin`,
    { method: "POST" }
  );
}
