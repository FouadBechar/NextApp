import React, { useState } from "react";
import { MoreVertical, Trash } from "lucide-react";
import Menu, { MenuTrigger, MenuContent, MenuItem } from "@/components/ui/menu";
import UserBadge from "@/components/forum/user-badge";
import { Button } from "@/components/ui/button";
import type { Thread } from "@/types/forum";

interface ThreadListProps {
  threads: Thread[];
  currentUserId?: string | null;
  selectedId?: string | null;
  onSelect: (thread: Thread) => void;
  onEdit: (thread: Thread) => void;
  onRequestDelete: (threadId: string) => void;
  onRequestReport: (threadId: string) => void;
  onTogglePin: (threadId: string) => void | Promise<void>;
  pinPendingIds?: Set<string>;
}

const pageSize = 10;

export default function ThreadList({
  threads,
  currentUserId,
  selectedId,
  onSelect,
  onEdit,
  onRequestDelete,
  onRequestReport,
  onTogglePin,
  pinPendingIds,
}: ThreadListProps) {
  const [page, setPage] = useState(0);

  return (
    <>
      <div className="space-y-3">
        {threads.length ? (
          threads
            .slice(page * pageSize, (page + 1) * pageSize)
            .map((t) => (
              <article
                key={t.id}
                className={`p-4 border rounded-md hover:shadow cursor-pointer group ${
                  selectedId === t.id ? "bg-muted" : ""
                }`}
                onClick={() => onSelect(t)}
                tabIndex={0}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault();
                    onSelect(t);
                  }
                }}
              >
                <div className="flex items-start justify-between">
                  <h3 className="font-semibold">
                    {t.title}
                    {t.pinned ? (
                      <span className="ml-2 inline-block rounded bg-primary px-2 py-0.5 text-xs text-primary-foreground">
                        Pinned
                      </span>
                    ) : null}
                  </h3>
                  {currentUserId && currentUserId === t.author_id && (
                    <div className="ml-4 relative opacity-0 group-hover:opacity-100 transition">
                      <Menu>
                        <MenuTrigger>
                          <Button asChild variant="ghost" size="icon" aria-label="Thread actions">
                            <button
                              id={`menu-thread-${t.id}-button`}
                              aria-controls={`menu-thread-${t.id}`}
                              title="Thread actions"
                            >
                              <MoreVertical className="h-4 w-4" />
                            </button>
                          </Button>
                        </MenuTrigger>
                        <MenuContent align="end" id={`menu-thread-${t.id}`}>
                          <MenuItem onSelect={() => onEdit(t)}>Edit</MenuItem>
                          <MenuItem
                            disabled={pinPendingIds?.has(t.id)}
                            onSelect={() => onTogglePin(t.id)}
                          >
                            {t.pinned ? "Unpin" : "Pin"}
                          </MenuItem>
                          <MenuItem onSelect={() => onRequestReport(t.id)}>
                            Report
                          </MenuItem>
                          <MenuItem
                            onSelect={() => onRequestDelete(t.id)}
                            className="text-destructive"
                          >
                            <Trash className="h-4 w-4" />
                            Delete
                          </MenuItem>
                        </MenuContent>
                      </Menu>
                    </div>
                  )}
                </div>
                <div className="text-sm text-muted-foreground mt-1 flex items-center gap-2">
                  <UserBadge
                    username={t.author_display ?? null}
                    avatarUrl={t.author_avatar_url ?? null}
                    userId={t.author_id}
                    size="sm"
                  />
                  <span className="text-sm text-muted-foreground">
                    {t.created_at ? new Date(t.created_at).toLocaleString() : ""}
                  </span>
                </div>
                <div className="text-sm text-muted-foreground mt-2">
                  {t.content
                    ? t.content.length > 180
                      ? t.content.slice(0, 180) + "…"
                      : t.content
                    : ""}
                </div>
                <div className="mt-2 text-xs text-muted-foreground">
                  {t.reply_count || 0} replies
                </div>
              </article>
            ))
        ) : (
          <div className="text-center py-8 text-muted-foreground">
            No discussions yet — be the first to start one.
          </div>
        )}
      </div>
      {threads.length > pageSize && (
        <div className="flex items-center justify-between mt-4">
          <div className="text-sm text-muted-foreground">
            Page {page + 1} of {Math.max(1, Math.ceil(threads.length / pageSize))}
          </div>
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>
              Prev
            </Button>
            <Button
              variant="ghost"
              onClick={() =>
                setPage((p) =>
                  Math.min(Math.max(0, Math.ceil(threads.length / pageSize) - 1), p + 1)
                )
              }
              disabled={(page + 1) * pageSize >= threads.length}
            >
              Next
            </Button>
          </div>
        </div>
      )}
    </>
  );
}
