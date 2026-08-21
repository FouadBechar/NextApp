import React from "react";
import UserBadge from "@/components/forum/user-badge";
import { MoreVertical, Trash } from "lucide-react";
import Menu, { MenuTrigger, MenuContent, MenuItem } from "@/components/ui/menu";
import { Button } from "@/components/ui/button";

type Post = {
  id: string;
  thread_id: string;
  content: string;
  author_id?: string;
  author_display?: string | null;
  author_avatar_url?: string | null;
  pinned?: boolean;
  created_at?: string;
};

type Props = {
  post: Post;
  currentUserId?: string | null;
  onEdit: (p: Post) => void;
  onDelete: (threadId: string, postId: string) => void;
  onReport: (payload: { threadId: string; postId: string }) => void;
  togglePin?: (p: Post) => void;
};

export default function PostItem({
  post,
  currentUserId,
  onEdit,
  onDelete,
  onReport,
  togglePin,
}: Props) {
  return (
    <div key={post.id} className="p-3 border rounded group">
      <div className="text-sm text-muted-foreground flex items-start justify-between gap-2">
        <div className="flex items-center gap-2">
          <UserBadge
            username={post.author_display ?? null}
            avatarUrl={post.author_avatar_url ?? null}
            userId={post.author_id}
            size="sm"
          />
          <span>
            {post.created_at ? new Date(post.created_at).toLocaleString() : ""}
          </span>
          {post.pinned ? (
            <span className="ml-2 inline-block rounded bg-primary px-2 py-0.5 text-xs text-primary-foreground">
              Pinned
            </span>
          ) : null}
        </div>

        {currentUserId && currentUserId === post.author_id && (
          <div className="ml-4 relative opacity-0 group-hover:opacity-100 transition">
            <Menu>
              <MenuTrigger>
                <Button asChild variant="ghost" size="icon" aria-label="Reply actions">
                  <button id={`menu-post-${post.id}-button`} aria-controls={`menu-post-${post.id}`} title="Reply actions">
                    <MoreVertical className="h-4 w-4" />
                  </button>
                </Button>
              </MenuTrigger>
              <MenuContent align="end" id={`menu-post-${post.id}`}>
                <MenuItem onSelect={() => onEdit(post)}>Edit</MenuItem>
                <MenuItem
                  onSelect={() => togglePin && togglePin(post)}
                >
                  {post.pinned ? "Unpin" : "Pin"}
                </MenuItem>
                <MenuItem onSelect={() => onReport({ threadId: post.thread_id, postId: post.id })}>Report</MenuItem>
                <MenuItem onSelect={() => onDelete(post.thread_id, post.id)} className="text-destructive">
                  <Trash className="h-4 w-4" />
                  Delete
                </MenuItem>
              </MenuContent>
            </Menu>
          </div>
        )}
      </div>
      <div className="mt-2">{post.content}</div>
    </div>
  );
}
