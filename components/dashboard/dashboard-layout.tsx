"use client";

import React, { useState, useEffect, useRef, useCallback, memo } from "react";
// import Modal from "@/components/ui/modal";
import { useRouter, usePathname } from "next/navigation";
import { createClient } from "@/utils/supabase/client";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme/theme-toggle";
// import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import AvatarUploader from "@/components/dashboard/avatar-uploader";
// import { toast } from "sonner";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import FocusLock from "react-focus-lock";
import Link from "next/link";
import { User } from "@supabase/supabase-js";
import { useTheme } from "next-themes";

type ThemePreference = "system" | "light" | "dark";

function parseThemePreference(value: unknown): ThemePreference | null {
  return value === "light" || value === "dark" || value === "system"
    ? value
    : null;
}

type ProfileApiResponse = {
  profile?: {
    avatar_url?: string | null;
    username?: string | null;
    full_name?: string | null;
    totp?: unknown;
    trustedDevice?: boolean | null;
    preferences?: {
      theme?: unknown;
    } | null;
  };
};

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);
  const mobileMenuButtonRef = useRef<HTMLButtonElement | null>(null);
  const mobileDrawerRef = useRef<HTMLDivElement | null>(null);
  const openMobileSidebar = useCallback(() => setIsMobileSidebarOpen(true), []);
  const closeMobileSidebar = useCallback(() => setIsMobileSidebarOpen(false), []);
  const [username, setUsername] = useState<string | null>(null);
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const previousActiveElementRef = useRef<HTMLElement | null>(null);
  const previousOverflowRef = useRef<string | null>(null);
  const mainRef = useRef<HTMLElement | null>(null);
  const fetchCountRef = useRef(0);
  const { setTheme: applyTheme } = useTheme();
  const applyThemeRef = useRef(applyTheme);

  useEffect(() => {
    applyThemeRef.current = applyTheme;
  }, [applyTheme]);

  // Manage focus & scroll lock when mobile drawer opens
  useEffect(() => {
    if (typeof document === "undefined") return;
    if (isMobileSidebarOpen) {
      previousActiveElementRef.current =
        document.activeElement as HTMLElement | null;
      // prevent body scrolling
      previousOverflowRef.current = document.body.style.overflow || "";
      document.body.style.overflow = "hidden";
      // Move focus into the drawer
      setTimeout(() => {
        try {
          const el = mobileDrawerRef.current;
          if (el) {
            const focusable = el.querySelector<HTMLElement>(
              'a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
            );
            if (focusable) focusable.focus();
            else el.focus();
          }
        } catch (e) {
          // ignore
        }
      }, 0);
    } else {
      // unlock and restore focus to the opener
      try {
        document.body.style.overflow = previousOverflowRef.current ?? "";
        previousOverflowRef.current = null;
      } catch (e) {
        /* ignore */
      }
      if (mobileMenuButtonRef.current) {
        try {
          mobileMenuButtonRef.current.focus();
        } catch (e) {
          // ignore
        }
      } else if (previousActiveElementRef.current) {
        try {
          previousActiveElementRef.current.focus();
        } catch (e) {
          /* ignore */
        }
      }
    }
    // cleanup
    return () => {
      try {
        document.body.style.overflow = previousOverflowRef.current ?? "";
        previousOverflowRef.current = null;
      } catch (e) {
        /* ignore */
      }
    };
  }, [isMobileSidebarOpen]);

  // Update `aria-hidden` on the main content using a DOM setter to avoid linter warnings
  useEffect(() => {
    try {
      if (mainRef.current) {
        mainRef.current.setAttribute(
          "aria-hidden",
          isMobileSidebarOpen ? "true" : "false"
        );
      }
    } catch (e) {
      // ignore DOM errors
    }
  }, [isMobileSidebarOpen]);
  const router = useRouter();
  const pathname = usePathname();
  const reduceMotion = useReducedMotion();

  useEffect(() => {
    async function getUser() {
      try {
        const supabase = createClient();
        const {
          data: { session },
        } = await supabase.auth.getSession();

        if (!session) {
          setUser(null);
          setUsername(null);
          setAvatarUrl(null);
          router.push("/auth/login");
          return;
        }

        setUser(session.user);
      } catch (error) {
        console.error("Error getting session:", error);
        setUser(null);
        setUsername(null);
        setAvatarUrl(null);
        router.push("/auth/login");
      } finally {
        setIsLoading(false);
      }
    }

    getUser();
  }, [router]);

  // When a user becomes available (login), automatically load their avatar so
  // it appears immediately after signing in instead of only when the user
  // clicks the avatar. This also refreshes signed URLs on each session.

  useEffect(() => {
    if (!user) {
      setUsername(null);
      setAvatarUrl(null);
      return;
    }

    const controller = new AbortController();
    const myId = ++fetchCountRef.current;

    (async () => {
      try {
        const res = await fetch(`/api/dashboard/profile?userId=${user.id}`, {
          credentials: "same-origin",
          signal: controller.signal,
        });
        if (!res.ok) {
          console.warn("Failed to load avatar on auth change", await res.text());
          return;
        }
        const json: ProfileApiResponse = await res.json();
        if (myId !== fetchCountRef.current) return; // stale, ignore
        const url = json?.profile?.avatar_url ?? null;
        const uname = json?.profile?.username ?? json?.profile?.full_name ?? null;
        const savedTheme = parseThemePreference(json?.profile?.preferences?.theme);
        const requiresTwoFactor = Boolean(json?.profile?.totp);
        const trustedDevice = Boolean(json?.profile?.trustedDevice);
        if (requiresTwoFactor && !trustedDevice) {
          router.replace(`/auth/2fa/verify?userId=${encodeURIComponent(user.id)}`);
          return;
        }

        // update avatarUrl even if already set to ensure latest signed URL
        setAvatarUrl(url);
        setUsername(uname);
        if (savedTheme) {
          applyThemeRef.current(savedTheme);
        }
      } catch (e: any) {
        if (e?.name === "AbortError") return; // aborted
        console.error("Error loading avatar on auth change", e);
      }
    })();

    // Refresh trusted-device last_seen on the server (if cookie present)
    (async () => {
      try {
        await fetch("/api/dashboard/trusted-devices/refresh", {
          method: "POST",
          credentials: "same-origin",
        });
      } catch (e) {
        // non-fatal
      }
    })();

    // cleanup: abort profile fetch on user change/unmount
    return () => controller.abort();
  }, [user]);

  useEffect(() => {
    setIsMobileSidebarOpen(false);
  }, [pathname]);

  const handleSignOut = useCallback(async () => {
    try {
      const supabase = createClient();
      await supabase.auth.signOut();
      router.push("/auth/login");
    } catch (error) {
      console.error("Error signing out:", error);
    }
  }, [router]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar (desktop) */}
      <motion.div
        initial={reduceMotion ? { opacity: 1, x: 0 } : { x: -20, opacity: 0 }}
        animate={{ x: 0, opacity: 1 }}
        transition={{ duration: reduceMotion ? 0 : 0.3 }}
        className={`${isSidebarOpen ? "w-64" : "w-20"} bg-card border-r border-border transition-all duration-300 ease-in-out flex flex-col hidden md:flex`}
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
            onClick={() => setIsSidebarOpen(v => !v)}
            aria-pressed={isSidebarOpen}
            aria-label={isSidebarOpen ? "Collapse sidebar" : "Expand sidebar"}
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
            isActive={pathname === "/dashboard"}
          />
          <SidebarItem
            href="/dashboard/profile"
            icon={<UserIcon className="h-5 w-5" />}
            label="Profile"
            isCollapsed={!isSidebarOpen}
            isActive={
              pathname === "/dashboard/profile" ||
              pathname.startsWith("/dashboard/profile/")
            }
          />
          <SidebarItem
            href="/dashboard/settings"
            icon={<SettingsIcon className="h-5 w-5" />}
            label="Settings"
            isCollapsed={!isSidebarOpen}
            isActive={
              pathname === "/dashboard/settings" ||
              pathname.startsWith("/dashboard/settings/")
            }
          />
        </nav>

        <div className="p-4 border-t border-border">
          <Button
            variant="ghost"
            className={`w-full ${isSidebarOpen ? "justify-start" : "justify-center"} text-muted-foreground hover:text-destructive`}
            onClick={handleSignOut}
          >
            <LogOutIcon className="h-5 w-5 mr-2" />
            {isSidebarOpen && <span>Sign out</span>}
          </Button>
        </div>
      </motion.div>

      {/* Mobile sidebar drawer */}
      <AnimatePresence>
        {isMobileSidebarOpen && (
          <div className="fixed inset-0 z-50 md:hidden" role="presentation">
            <div
              className="absolute inset-0 bg-black/40"
              onClick={closeMobileSidebar}
            />
            <motion.div
              id="mobile-sidebar"
              tabIndex={-1}
              initial={reduceMotion ? { x: 0 } : { x: -300 }}
              animate={{ x: 0 }}
              exit={reduceMotion ? { x: 0 } : { x: -300 }}
              transition={reduceMotion ? { duration: 0 } : { type: "tween" }}
              className="relative z-50 w-64 h-full bg-card border-r border-border flex flex-col"
              role="dialog"
              aria-modal="true"
              aria-labelledby="mobile-sidebar-title"
              ref={mobileDrawerRef}
              onKeyDown={(e) => {
                // Escape closes the drawer
                if (e.key === "Escape") {
                  e.stopPropagation();
                  closeMobileSidebar();
                }
              }}
            >
              <FocusLock
                disabled={!isMobileSidebarOpen}
                returnFocus={true}
                autoFocus={true}
              >
                <div className="p-4 flex items-center justify-between border-b border-border">
                  <h2 id="mobile-sidebar-title" className="sr-only">
                    Dashboard navigation
                  </h2>
                  <Link href="/dashboard" className="flex items-center">
                    <span className="text-xl font-bold">Dashboard</span>
                  </Link>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={closeMobileSidebar}
                    aria-label="Close menu"
                    className="text-muted-foreground"
                  >
                    <ChevronLeftIcon className="h-5 w-5" />
                  </Button>
                </div>

                <nav className="flex-1 p-4 space-y-2">
                  <SidebarItem
                    href="/dashboard"
                    icon={<HomeIcon className="h-5 w-5" />}
                    label="Home"
                    isCollapsed={false}
                    isActive={pathname === "/dashboard"}
                    onClick={closeMobileSidebar}
                  />
                  <SidebarItem
                    href="/dashboard/profile"
                    icon={<UserIcon className="h-5 w-5" />}
                    label="Profile"
                    isCollapsed={false}
                    isActive={
                      pathname === "/dashboard/profile" ||
                      pathname.startsWith("/dashboard/profile/")
                    }
                    onClick={closeMobileSidebar}
                  />
                  <SidebarItem
                    href="/dashboard/settings"
                    icon={<SettingsIcon className="h-5 w-5" />}
                    label="Settings"
                    isCollapsed={false}
                    isActive={
                      pathname === "/dashboard/settings" ||
                      pathname.startsWith("/dashboard/settings/")
                    }
                    onClick={closeMobileSidebar}
                  />
                </nav>

                <div className="p-4 border-t border-border">
                  <Button
                    variant="ghost"
                    className="w-full justify-start text-muted-foreground hover:text-destructive"
                    onClick={handleSignOut}
                  >
                    <LogOutIcon className="h-5 w-5 mr-2" />
                    <span>Sign out</span>
                  </Button>
                </div>
              </FocusLock>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="h-16 border-b border-border bg-card flex items-center justify-between px-4 md:px-6">
          <div className="flex items-center">
            {/* Mobile menu button (shows mobile sidebar) */}
            <div className="mr-3 md:hidden">
              <Button
                variant="ghost"
                size="icon"
                onClick={openMobileSidebar}
                aria-label="Open menu"
                aria-controls="mobile-sidebar"
                aria-expanded={isMobileSidebarOpen}
                ref={mobileMenuButtonRef}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path
                    fillRule="evenodd"
                    d="M3 5h14a1 1 0 010 2H3a1 1 0 010-2zm0 4h14a1 1 0 010 2H3a1 1 0 010-2zm0 4h14a1 1 0 010 2H3a1 1 0 010-2z"
                    clipRule="evenodd"
                  />
                </svg>
              </Button>
            </div>
            <h1 className="text-lg md:text-xl font-semibold">
              Welcome,{" "}
              <span className="text-primary">{username ?? user?.email}</span>
            </h1>
          </div>
          <div className="flex items-center space-x-4">
            <ThemeToggle />
            <AvatarUploader
              userId={user?.id}
              initialAvatarUrl={avatarUrl}
              displayName={username ?? user?.email}
              className="h-8 w-8"
              onUpload={(publicUrl) => setAvatarUrl(publicUrl)}
            />
          </div>
        </header>

        {/* Content */}

        <main ref={mainRef} className="flex-1 overflow-auto p-4 md:p-6">
          <div className="max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}

interface SidebarItemProps {
  href: string;
  icon: React.ReactNode;
  label: string;
  isCollapsed: boolean;
  isActive?: boolean;
  onClick?: () => void;
}

const SidebarItem = memo(function SidebarItem({
  href,
  icon,
  label,
  isCollapsed,
  isActive,
  onClick,
}: SidebarItemProps) {
  return (
    <Link
      href={href}
      onClick={onClick}
      aria-current={isActive ? "page" : undefined}
      className={`flex items-center p-2 rounded-md transition-colors ${isActive ? 'bg-accent text-foreground' : 'hover:bg-accent group'}`}
    >
      <div className={`${isActive ? 'mr-2 text-foreground' : 'mr-2 text-muted-foreground group-hover:text-foreground'}`}>
        {icon}
      </div>
      {!isCollapsed && (
        <span className={isActive ? 'text-foreground' : 'text-muted-foreground group-hover:text-foreground'}>
          {label}
        </span>
      )}
    </Link>
  );
});

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
