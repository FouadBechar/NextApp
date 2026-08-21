import React from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import UserBadge from "@/components/forum/user-badge";

type Props = {
  value: string;
  onChange: (v: string) => void;
  onSubmit: (e?: React.FormEvent) => Promise<void> | void;
  isExpanded: boolean;
  onExpand: () => void;
  onCancel: () => void;
  currentUser?: {
    id?: string | null;
    username?: string | null;
    avatar_url?: string | null;
  } | null;
  currentUserLoading?: boolean;
  posting?: boolean;
  maxLength?: number;
  id?: string;
  onFocus?: (e: React.FocusEvent<HTMLTextAreaElement>) => void;
  onBlur?: (e: React.FocusEvent<HTMLTextAreaElement>) => void;
  onSelect?: (e: React.SyntheticEvent<HTMLTextAreaElement>) => void;
};

export default function ReplyForm({
  value,
  onChange,
  onSubmit,
  isExpanded,
  onExpand,
  onCancel,
  currentUser,
  currentUserLoading = false,
  posting = false,
  maxLength = 5000,
  id,
  onFocus,
  onBlur,
  onSelect,
}: Props) {
  const remaining = Math.max(0, maxLength - (value?.length || 0));
  const canSubmit = Boolean(value.trim()) && !posting;

  if (currentUserLoading) {
    return (
      <div className="rounded-md border bg-muted/20 p-4">
        <div className="h-4 w-32 rounded bg-muted" />
        <div className="mt-3 h-10 rounded-md border bg-background" />
      </div>
    );
  }

  if (!currentUser?.id) {
    return (
      <div className="rounded-md border bg-muted/30 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <div className="text-sm font-medium">Join the discussion</div>
            <div className="text-sm text-muted-foreground">
              Sign in to write a reply.
            </div>
          </div>
          <Button asChild size="sm">
            <Link href="/auth/login">Sign in</Link>
          </Button>
        </div>
      </div>
    );
  }

  if (!isExpanded) {
    return (
      <button
        type="button"
        onClick={onExpand}
        className="flex w-full items-center gap-3 rounded-md border bg-muted/20 p-3 text-left transition hover:bg-muted/40 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
      >
        <UserBadge
          username={currentUser.username ?? null}
          avatarUrl={currentUser.avatar_url ?? null}
          userId={currentUser.id}
          showProfileLink={false}
        />
        <span className="min-w-0 flex-1 rounded-md border bg-background px-3 py-2 text-sm text-muted-foreground">
          Write a reply...
        </span>
      </button>
    );
  }

  return (
    <form onSubmit={onSubmit} className="rounded-md border bg-muted/20 p-4">
      <div className="mb-3 flex items-center justify-between gap-3">
        <UserBadge
          username={currentUser.username ?? null}
          avatarUrl={currentUser.avatar_url ?? null}
          userId={currentUser.id}
          showProfileLink={false}
        />
        <div className="text-xs text-muted-foreground">
          Ctrl/Cmd + Enter to post
        </div>
      </div>

      <textarea
        id={id}
        aria-label="Reply content"
        placeholder="Write a thoughtful reply..."
        value={value}
        maxLength={maxLength}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={(e) => {
          if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
            e.preventDefault();
            if (canSubmit) {
              onSubmit();
            }
          }
          e.stopPropagation();
        }}
        rows={4}
        onFocus={onFocus}
        onBlur={onBlur}
        onSelect={onSelect}
        disabled={posting}
        autoFocus
        className="border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground w-full resize-y rounded-md border bg-background px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
      />

      <div className="flex items-center justify-between mt-2">
        <div className="text-xs text-muted-foreground">{remaining} characters left</div>
        <div className="flex gap-2">
          <Button type="button" variant="ghost" onClick={onCancel} disabled={posting}>
            Cancel
          </Button>
          <Button type="submit" disabled={!canSubmit}>
            {posting ? "Posting…" : "Reply"}
          </Button>
        </div>
      </div>
    </form>
  );
}
