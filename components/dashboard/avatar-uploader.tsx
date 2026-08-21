"use client";

import { useEffect, useId, useRef, useState } from "react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  getInitials,
  generateAvatarGradientClass,
} from "@/components/ui/avatar-utils";
import { transformImageToSquare } from "./image-utils";
import Modal from "@/components/ui/modal";
import SafeImage from "@/components/ui/SafeImage";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

type Props = {
  userId?: string | null;
  initialAvatarUrl?: string | null;
  displayName?: string | null;
  className?: string; // tailwind classes for size
  isLoading?: boolean; // external loading flag (e.g., initial fetch)
  onUpload?: (publicUrl: string | null, path?: string | null) => void;
};

export default function AvatarUploader({
  userId,
  initialAvatarUrl = null,
  displayName = null,
  className = "h-10 w-10",
  isLoading = false,
  onUpload,
}: Props) {
  const SERVER_UPLOAD_MAX_BYTES = 5 * 1024 * 1024; // avatar-sharp route limit
  const MAX_UPLOAD_LABEL = "5 MB";
  const [avatarUrl, setAvatarUrl] = useState<string | null>(
    initialAvatarUrl === "" ? null : (initialAvatarUrl ?? null)
  );
  const [isAvatarLoading, setIsAvatarLoading] = useState(false);
  // keep previous avatar so we can restore it if user cancels or upload fails
  const [prevAvatarUrl, setPrevAvatarUrl] = useState<string | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [previewFile, setPreviewFile] = useState<File | null>(null);
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [previewMeta, setPreviewMeta] = useState<{
    width?: number;
    height?: number;
    size?: number;
  } | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const inputId = useId();
  const CLIENT_MAX_BYTES = SERVER_UPLOAD_MAX_BYTES;

  function resetPreviewState() {
    setPreviewUrl(null);
    setPreviewFile(null);
    setPreviewMeta(null);
    setIsPreviewOpen(false);
  }

  useEffect(() => {
    setAvatarUrl((prev) => {
      const next = initialAvatarUrl === "" ? null : (initialAvatarUrl ?? null);
      if (prev === next) return prev;
      try {
        if (typeof prev === "string" && prev.startsWith("blob:")) {
          URL.revokeObjectURL(prev);
        }
      } catch (e) {
        /* ignore */
      }
      return next;
    });
  }, [initialAvatarUrl, userId]);

  // cleanup on unmount (and when avatar/preview change): revoke any blob URLs to avoid leaks
  useEffect(() => {
    return () => {
      try {
        if (
          avatarUrl &&
          typeof avatarUrl === "string" &&
          avatarUrl.startsWith("blob:")
        ) {
          URL.revokeObjectURL(avatarUrl);
        }
      } catch (e) {
        /* ignore */
      }
      try {
        if (
          previewUrl &&
          typeof previewUrl === "string" &&
          previewUrl.startsWith("blob:")
        ) {
          URL.revokeObjectURL(previewUrl);
        }
      } catch (e) {
        /* ignore */
      }
    };
  }, [avatarUrl, previewUrl]);

  async function loadAvatar() {
    if (avatarUrl || !userId) return;
    const ac = new AbortController();
    try {
      setIsAvatarLoading(true);
      const res = await fetch(
        `/api/dashboard/profile?userId=${encodeURIComponent(userId)}`,
        { credentials: "same-origin", signal: ac.signal }
      );
      if (res.ok) {
        const json: ProfileApiResponse = await res.json();
        const url = json?.profile?.avatar_url ?? null;
        if (url) setAvatarUrl(url);
      }
    } catch (e) {
      if ((e as any)?.name === "AbortError") return;
      console.error("AvatarUploader loadAvatar error", e);
    } finally {
      setIsAvatarLoading(false);
      try {
        ac.abort();
      } catch (e) {
        /* ignore */
      }
    }
  }

  function handleClick() {
    // allow parent to trigger a load of avatar if not present
    if (!avatarUrl && userId) loadAvatar();
    fileInputRef.current?.click();
  }

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > CLIENT_MAX_BYTES) {
      toast.error(`File is too large. Maximum allowed size is ${MAX_UPLOAD_LABEL}.`);
      if (fileInputRef.current) fileInputRef.current.value = "";
      return;
    }
    try {
      setIsAvatarLoading(true);
      const processedFile = await transformImageToSquare(file, 512);
      const url = URL.createObjectURL(processedFile as Blob);
      if (processedFile.size > SERVER_UPLOAD_MAX_BYTES) {
        URL.revokeObjectURL(url);
        toast.error(
          `Processed avatar is still too large. Maximum allowed size is ${MAX_UPLOAD_LABEL}.`
        );
        return;
      }

      // keep previous avatar so we can restore if upload/cancel happens
      setPrevAvatarUrl(avatarUrl);
      if (previewUrl && previewUrl !== url) {
        try {
          URL.revokeObjectURL(previewUrl);
        } catch (e) {
          /* ignore */
        }
      }
      setPreviewUrl(url);
      // show optimistic preview immediately as the avatar
      setAvatarUrl(url);
      setPreviewFile(processedFile);
      try {
        const img = new Image();
        img.onload = () => {
          setPreviewMeta({
            width: img.width,
            height: img.height,
            size: processedFile.size,
          });
          setIsPreviewOpen(true);
        };
        img.onerror = () => {
          setPreviewMeta({ size: processedFile.size });
          setIsPreviewOpen(true);
        };
        img.src = url;
      } catch (e) {
        setPreviewMeta({ size: processedFile.size });
        setIsPreviewOpen(true);
      }
    } catch (err: unknown) {
      const e = err as Error;
      console.error("AvatarUploader processing error", e);
      toast.error("Failed to process image for preview");
    } finally {
      setIsAvatarLoading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  }

  async function uploadProcessedAvatar() {
    if (!previewFile) return;
    setIsUploading(true);
    try {
      const form = new FormData();
      form.append("file", previewFile as Blob);
      form.append("filename", previewFile.name);
      const res = await fetch("/api/dashboard/avatar-sharp", {
        method: "POST",
        body: form,
        credentials: "same-origin",
      });
      const contentType = res.headers.get("content-type") || "";
      let json: AvatarUploadResponse | null = null;
      if (contentType.includes("application/json")) json = await res.json();
      if (!res.ok) {
        const message = json?.error?.message || (await res.text());
        toast.error(message || "Avatar upload failed");
        // revert optimistic preview on failure
        setAvatarUrl(prevAvatarUrl);
        return;
      }
      const publicUrl = json?.publicUrl || null;
      const path = json?.path || null;
      if (publicUrl) {
        setAvatarUrl(publicUrl);
        toast.success("Avatar uploaded");
        // revoke previous blob URL if we used one for optimistic preview
        try {
          if (
            prevAvatarUrl &&
            prevAvatarUrl.startsWith("blob:") &&
            prevAvatarUrl !== publicUrl
          ) {
            URL.revokeObjectURL(prevAvatarUrl);
          }
        } catch (e) {
          /* ignore */
        }
      }
      if (onUpload) onUpload(publicUrl ?? null, path ?? null);

      // cleanup preview blob only if it's not the currently displayed avatar
      if (previewUrl && previewUrl !== publicUrl) {
        try {
          URL.revokeObjectURL(previewUrl);
        } catch (e) {
          /* ignore */
        }
      }
      resetPreviewState();
      setPrevAvatarUrl(null);
    } catch (err: unknown) {
      const e = err as Error;
      console.error("AvatarUploader upload error", e);
      toast.error("Failed to upload avatar");
      // revert optimistic preview on error
      setAvatarUrl(prevAvatarUrl);
      if (previewUrl) {
        try {
          URL.revokeObjectURL(previewUrl);
        } catch (e) {
          /* ignore */
        }
      }
      setPrevAvatarUrl(null);
      setPreviewMeta(null);
      setPreviewFile(null);
      setPreviewUrl(null);
      setIsPreviewOpen(false);
    } finally {
      setIsUploading(false);
    }
  }

  function cancelPreview() {
    // If we were showing the preview as the avatar, restore previous avatar
    if (previewUrl) {
      if (avatarUrl === previewUrl) {
        setAvatarUrl(prevAvatarUrl);
      }
      try {
        URL.revokeObjectURL(previewUrl);
      } catch (e) {
        /* ignore */
      }
    }
    setPrevAvatarUrl(null);
    resetPreviewState();
  }

  // `transformImageToSquare` moved to `components/dashboard/image-utils.ts`
  // The implementation remains the same; import above and use it.

  return (
    <div>
      <label htmlFor={inputId} className="sr-only">
        Upload avatar
      </label>
      <input
        ref={fileInputRef}
        id={inputId}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleFileChange}
      />
      <div
        role="button"
        tabIndex={0}
        title="Change avatar"
        onClick={handleClick}
        onKeyDown={(e: React.KeyboardEvent<HTMLDivElement>) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            handleClick();
          }
        }}
        className="cursor-pointer inline-block"
        aria-label={
          displayName ? `Change avatar for ${displayName}` : "Change avatar"
        }
      >
        <div className="relative inline-block">
          <Avatar
            className={className}
            aria-label={displayName ? `${displayName} avatar` : "avatar"}
          >
            {avatarUrl ? (
              <SafeImage
                src={avatarUrl}
                alt={displayName ? `${displayName} avatar` : "avatar"}
              />
            ) : (
              <AvatarFallback
                className={generateAvatarGradientClass(
                  displayName ?? userId ?? ""
                )}
              >
                <span className="sr-only">
                  {displayName ? `${displayName} avatar` : "avatar"}
                </span>
                <span className="text-sm" aria-hidden>
                  {getInitials(displayName ?? userId ?? "")}
                </span>
              </AvatarFallback>
            )}
          </Avatar>
          {(isAvatarLoading || isLoading) && (
            <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-full">
              <div className="animate-spin h-4 w-4 border-2 border-t-transparent border-white rounded-full" />
            </div>
          )}
        </div>
      </div>

      {previewUrl && (
        <Modal
          open={isPreviewOpen}
          onClose={() => {
            if (!isUploading) cancelPreview();
          }}
          ariaLabel="Avatar preview"
        >
          <div className="flex flex-col items-center space-y-4">
            <SafeImage
              src={previewUrl}
              alt="Avatar preview"
              className="max-h-[70vh] max-w-full rounded-lg object-contain"
            />
            <div className="text-sm text-muted-foreground text-center">
              {previewFile?.name && <div>File: {previewFile.name}</div>}
              {previewMeta?.width && previewMeta?.height && (
                <div>
                  Dimensions: {previewMeta.width} × {previewMeta.height}px
                </div>
              )}
              {previewMeta?.size && (
                <div>Size: {(previewMeta.size / 1024).toFixed(1)} KB</div>
              )}
            </div>
            <div className="flex items-center space-x-2">
              <Button
                onClick={() => {
                  uploadProcessedAvatar();
                }}
                disabled={isUploading}
              >
                {isUploading ? "Uploading…" : "Upload"}
              </Button>
              <Button
                variant="ghost"
                onClick={() => {
                  cancelPreview();
                }}
                disabled={isUploading}
              >
                Cancel
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}

// utilities moved to components/ui/avatar-utils.ts
