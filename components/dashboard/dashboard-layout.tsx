'use client';

import { useState, useEffect } from 'react';
import { useRef } from 'react';
import Modal from '@/components/ui/modal';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { ThemeToggle } from '@/components/theme/theme-toggle';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { toast } from 'sonner';
import { motion } from 'framer-motion';
import Link from 'next/link';
import { User } from '@supabase/supabase-js';

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const router = useRouter();

  useEffect(() => {
    async function getUser() {
      const supabase = createClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session) {
        router.push('/auth/login');
        return;
      }

      setUser(session.user);
      // do not block rendering while we fetch the profile avatar
      // avatar will be loaded on demand (click) or we can prefetch here
      // keep minimal initial payload
      setIsLoading(false);
    }

    getUser();
  }, [router]);

  // When a user becomes available (login), automatically load their avatar so
  // it appears immediately after signing in instead of only when the user
  // clicks the avatar. This also refreshes signed URLs on each session.
  useEffect(() => {
    if (!user) return;

    (async () => {
      try {
        setIsAvatarLoading(true);
        const res = await fetch(`/api/dashboard/profile?userId=${user.id}`, {
          credentials: 'same-origin',
        });
        if (res.ok) {
          const json = await res.json();
          const url = json?.profile?.avatar || null;
          // update avatarUrl even if already set to ensure latest signed URL
          if (url) setAvatarUrl(url);
        } else {
          console.warn('Failed to load avatar on auth change', await res.text());
        }
      } catch (e) {
        console.error('Error loading avatar on auth change', e);
      } finally {
        setIsAvatarLoading(false);
      }
    })();
    // Refresh trusted-device last_seen on the server (if cookie present)
    (async () => {
      try {
        await fetch('/api/dashboard/trusted-devices/refresh', { method: 'POST', credentials: 'same-origin' });
      } catch (e) {
        // non-fatal
      }
    })();
  }, [user]);

  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const [isAvatarLoading, setIsAvatarLoading] = useState(false);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [previewFile, setPreviewFile] = useState<File | null>(null);
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [previewMeta, setPreviewMeta] = useState<{ width?: number; height?: number; size?: number } | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const CLIENT_MAX_BYTES = 5 * 1024 * 1024; // 5 MB client-side guard

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !user) return;

    // quick client-side size check to avoid creating huge canvases
    if (file.size > CLIENT_MAX_BYTES) {
      toast.error(`File is too large. Maximum allowed size is ${Math.round(CLIENT_MAX_BYTES / 1024 / 1024)} MB.`);
      if (fileInputRef.current) fileInputRef.current.value = '';
      return;
    }

    try {
      setIsAvatarLoading(true);

      // Transform the image into a centered square and resize in-browser
      // to a reasonable size for preview/upload.
      const processedFile = await transformImageToSquare(file, 512);

      // Create an object URL for preview and keep the processed File until user confirms upload
      const url = URL.createObjectURL(processedFile as Blob);
      // revoke previous preview if any
      if (previewUrl) URL.revokeObjectURL(previewUrl);
      setPreviewUrl(url);
      setPreviewFile(processedFile);
      // compute preview metadata (dimensions + size) and open preview
      try {
        const img = new Image();
        img.onload = () => {
          setPreviewMeta({ width: img.width, height: img.height, size: processedFile.size });
          setIsPreviewOpen(true);
        };
        img.onerror = () => {
          // still open preview but without dimensions
          setPreviewMeta({ size: processedFile.size });
          setIsPreviewOpen(true);
        };
        img.src = url;
      } catch (e) {
        setPreviewMeta({ size: processedFile.size });
        setIsPreviewOpen(true);
      }

      // Do NOT auto-upload here; wait for user to confirm in preview UI
    } catch (err) {
      console.error('Error processing avatar for preview', err);
      toast.error('Failed to process image for preview');
    } finally {
      setIsAvatarLoading(false);
      // clear file input so same file can be re-selected later
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  }

  async function uploadProcessedAvatar() {
    if (!previewFile || !user) return;
    setIsUploading(true);
    try {
      // Upload to server-side sharp processor
      const form = new FormData();
      form.append('file', previewFile);
      form.append('filename', previewFile.name);

      const res = await fetch('/api/dashboard/avatar-sharp', {
        method: 'POST',
        body: form,
        credentials: 'same-origin',
      });

      const contentType = res.headers.get('content-type') || '';
      let json: any = null;
      if (contentType.includes('application/json')) json = await res.json();

      if (!res.ok) {
        const message = json?.error?.message || (await res.text());
        toast.error(message || 'Avatar upload failed');
        console.error('Avatar-sharp upload failed', message);
        return;
      }

      const publicUrl = json?.publicUrl || null;
      if (publicUrl) {
        setAvatarUrl(publicUrl);
        toast.success('Avatar uploaded');
      }

      // Persist via profile POST to keep profile.avatar_path consistent (server already persisted, but keep idempotent)
      try {
        const p = await fetch('/api/dashboard/profile', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({ userId: user.id, avatar_path: json?.path }),
        });
        if (!p.ok) {
          const txt = await p.text();
          console.warn('Failed to persist avatar path in profile', txt);
        }
      } catch (err) {
        console.error('Error persisting avatar path', err);
      }

      // Cleanup preview
      if (previewUrl) URL.revokeObjectURL(previewUrl);
      setPreviewUrl(null);
      setPreviewFile(null);
    } catch (err) {
      console.error('Upload processed avatar error', err);
      toast.error('Failed to upload avatar');
    } finally {
      setIsUploading(false);
    }
  }

  function cancelPreview() {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    setPreviewUrl(null);
    setPreviewFile(null);
    setPreviewMeta(null);
    setIsPreviewOpen(false);
  }
 

  // Resize & center-crop an image file to a square in the browser.
  // Returns a new File with the same name and a resized image blob.
  async function transformImageToSquare(file: File, size = 512): Promise<File> {
    // Use createObjectURL + Image for best cross-browser compatibility
    return new Promise<File>((resolve, reject) => {
      const url = URL.createObjectURL(file);
      const img = new Image();
      img.onload = () => {
        try {
          const minSide = Math.min(img.width, img.height);
          const sx = Math.floor((img.width - minSide) / 2);
          const sy = Math.floor((img.height - minSide) / 2);

          const canvas = document.createElement('canvas');
          canvas.width = size;
          canvas.height = size;
          const ctx = canvas.getContext('2d');
          if (!ctx) throw new Error('Canvas 2D context unavailable');

          // Draw the centered square region and scale to requested size
          ctx.drawImage(img, sx, sy, minSide, minSide, 0, 0, size, size);

          // Choose output type: prefer original image type when possible,
          // but convert PNG-like types to PNG and others to JPEG.
          const outputType = file.type === 'image/png' || file.type === 'image/webp' ? file.type : 'image/jpeg';
          canvas.toBlob(
            (blob) => {
              URL.revokeObjectURL(url);
              if (!blob) return reject(new Error('Failed to convert canvas to blob'));
              // Preserve filename, but ensure extension matches mime when possible
              let name = file.name;
              // If original extension differs from output mime, swap extension
              try {
                const extMap: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };
                const wantedExt = extMap[outputType] || 'jpg';
                // strip existing extension and append
                const base = name.replace(/\.[^.]+$/, '');
                name = `${base}.${wantedExt}`;
              } catch (e) {
                // ignore extension normalization failures
              }

              const newFile = new File([blob], name, { type: blob.type });
              resolve(newFile);
            },
            outputType,
            0.92,
          );
        } catch (err) {
          URL.revokeObjectURL(url);
          reject(err);
        }
      };
      img.onerror = (err) => {
        URL.revokeObjectURL(url);
        reject(err);
      };
      img.src = url;
    });
  }

  // Ensure preview object URL is revoked on unmount
  useEffect(() => {
    return () => {
      if (previewUrl) {
        try {
          URL.revokeObjectURL(previewUrl);
        } catch (e) {
          /* ignore */
        }
      }
    };
  }, [previewUrl]);

  function handleAvatarClick() {
    // attempt to load avatar metadata, then open file picker
    loadAvatar();
    fileInputRef.current?.click();
  }

  async function loadAvatar() {
    if (avatarUrl || !user) return;
    try {
      setIsAvatarLoading(true);
      // include credentials so cookies are sent for server-side session verification
      const res = await fetch(`/api/dashboard/profile?userId=${user.id}`, {
        credentials: 'same-origin',
      });
      if (res.ok) {
        const json = await res.json();
        const url = json?.profile?.avatar || null;
        if (url) setAvatarUrl(url);
      } else {
        console.warn('Failed to load avatar', await res.text());
      }
    } catch (e) {
      console.error('Error loading avatar', e);
    } finally {
      setIsAvatarLoading(false);
    }
  }

  async function handleSignOut() {
    try {
      const supabase = createClient();
      await supabase.auth.signOut();
      router.push('/auth/login');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  }

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar */}
      <motion.div
        initial={{ x: -20, opacity: 0 }}
        animate={{ x: 0, opacity: 1 }}
        transition={{ duration: 0.3 }}
        className={`${isSidebarOpen ? 'w-64' : 'w-20'} bg-card border-r border-border transition-all duration-300 ease-in-out flex flex-col`}
      >
        <div className="p-4 flex items-center justify-between border-b border-border">
          <Link href="/dashboard" className="flex items-center">
            {isSidebarOpen ? (
              <span className="text-xl font-bold">Dashboard</span>
            ) : (
              <span className="text-xl font-bold">D</span>
            )}
          </Link>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsSidebarOpen(!isSidebarOpen)}
            className="text-muted-foreground"
          >
            {isSidebarOpen ? (
              <ChevronLeftIcon className="h-5 w-5" />
            ) : (
              <ChevronRightIcon className="h-5 w-5" />
            )}
          </Button>
        </div>

        <nav className="flex-1 p-4 space-y-2">
          <SidebarItem
            href="/dashboard"
            icon={<HomeIcon className="h-5 w-5" />}
            label="Home"
            isCollapsed={!isSidebarOpen}
          />
          <SidebarItem
            href="/dashboard/profile"
            icon={<UserIcon className="h-5 w-5" />}
            label="Profile"
            isCollapsed={!isSidebarOpen}
          />
          <SidebarItem
            href="/dashboard/settings"
            icon={<SettingsIcon className="h-5 w-5" />}
            label="Settings"
            isCollapsed={!isSidebarOpen}
          />
        </nav>

        <div className="p-4 border-t border-border">
          <Button
            variant="ghost"
            className={`w-full justify-${isSidebarOpen ? 'start' : 'center'} text-muted-foreground hover:text-destructive`}
            onClick={handleSignOut}
          >
            <LogOutIcon className="h-5 w-5 mr-2" />
            {isSidebarOpen && <span>Sign out</span>}
          </Button>
        </div>
      </motion.div>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="h-16 border-b border-border bg-card flex items-center justify-between px-6">
          <div className="flex items-center">
            <h1 className="text-xl font-semibold">
              Welcome, <span className="text-primary">{user?.email}</span>
            </h1>
          </div>
          <div className="flex items-center space-x-4">
            <ThemeToggle />
            <div>
              <label htmlFor="avatar-upload" className="sr-only">
                Upload avatar
              </label>
              <input
                ref={fileInputRef}
                id="avatar-upload"
                aria-label="Upload avatar"
                title="Upload avatar"
                placeholder="Upload avatar"
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleFileChange}
              />
              <div onClick={handleAvatarClick} title="Change avatar" role="button" className="cursor-pointer">
                <div className="relative">
                  <Avatar className="h-8 w-8">
                    {avatarUrl ? (
                      <AvatarImage src={avatarUrl} alt={user?.email || 'avatar'} />
                    ) : (
                      <AvatarFallback>{user?.email?.charAt(0).toUpperCase()}</AvatarFallback>
                    )}
                  </Avatar>
                  {isAvatarLoading && (
                    <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-full">
                      <div className="animate-spin h-4 w-4 border-2 border-t-transparent border-white rounded-full" />
                    </div>
                  )}
                </div>
              </div>
              {/* Preview panel: show processed image and Upload/Cancel actions */}
              {previewUrl && (
                <div className="ml-4 flex items-center space-x-3">
                  <Modal open={isPreviewOpen} onClose={() => { cancelPreview(); }} ariaLabel="Avatar preview">
                    <div className="flex flex-col items-center space-y-4">
                      <img src={previewUrl} alt="Avatar preview large" className="max-h-[70vh] max-w-full rounded-lg object-contain" />
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
                        <Button onClick={() => { uploadProcessedAvatar(); setIsPreviewOpen(false); }} disabled={isUploading}>
                          {isUploading ? 'Uploading…' : 'Upload'}
                        </Button>
                        <Button variant="ghost" onClick={() => { cancelPreview(); }} disabled={isUploading}>
                          Cancel
                        </Button>
                      </div>
                    </div>
                  </Modal>
                </div>
              )}
            </div>
          </div>
        </header>

        {/* Content */}
        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  );
}

interface SidebarItemProps {
  href: string;
  icon: React.ReactNode;
  label: string;
  isCollapsed: boolean;
}

function SidebarItem({ href, icon, label, isCollapsed }: SidebarItemProps) {
  return (
    <Link
      href={href}
      className="flex items-center p-2 rounded-md hover:bg-accent group transition-colors"
    >
      <div className="mr-2 text-muted-foreground group-hover:text-foreground">
        {icon}
      </div>
      {!isCollapsed && (
        <span className="text-muted-foreground group-hover:text-foreground">
          {label}
        </span>
      )}
    </Link>
  );
}

// Icons
function HomeIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
      <polyline points="9 22 9 12 15 12 15 22" />
    </svg>
  );
}

function UserIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  );
}

function SettingsIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function LogOutIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
      <polyline points="16 17 21 12 16 7" />
      <line x1="21" y1="12" x2="9" y2="12" />
    </svg>
  );
}

function ChevronLeftIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="m15 18-6-6 6-6" />
    </svg>
  );
}

function ChevronRightIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="m9 18 6-6-6-6" />
    </svg>
  );
}
 