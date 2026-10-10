"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useState, useEffect, useMemo, useRef } from "react";
import { User } from "@supabase/supabase-js";
import { toast } from "sonner";
import { Copy, ShieldCheck } from "lucide-react";
import { createClient } from "@/utils/supabase/client";
import {
  login as authLogin,
  updatePassword as authUpdatePassword,
} from "@/lib/utils/auth-helpers";

import { motion } from "framer-motion";
import Modal from "@/components/ui/modal";
import AvatarUploader from "@/components/dashboard/avatar-uploader";
import SafeImage from "@/components/ui/SafeImage";
import EyeIcon from "@/components/icons/eye";
import EyeOffIcon from "@/components/icons/eye-off";
import ActivitySection from "@/components/dashboard/activity-section";

export default function ProfilePage() {
  const supabaseRef = useRef<ReturnType<typeof createClient> | null>(null);

  function getSupabaseClient() {
    if (supabaseRef.current) return supabaseRef.current;
    supabaseRef.current = createClient();
    return supabaseRef.current;
  }

  const [show2FAModal, setShow2FAModal] = useState(false);
  const [isSettingUp2FA, setIsSettingUp2FA] = useState(false);
  const [setupData, setSetupData] = useState<{
    secret?: string;
    otpauth?: string;
    qrDataUrl?: string;
  } | null>(null);
  const [verifyToken, setVerifyToken] = useState("");
  const [isVerifying2FA, setIsVerifying2FA] = useState(false);
  const [twoFAError, setTwoFAError] = useState<string | null>(null);
  const verify2FAButtonRef = useRef<HTMLButtonElement | null>(null);
  // Email notifications settings
  const [showEmailSettingsModal, setShowEmailSettingsModal] = useState(false);
  const [emailNotificationsEnabled, setEmailNotificationsEnabled] = useState<
    boolean | null
  >(null);
  const [isSavingEmailSettings, setIsSavingEmailSettings] = useState(false);
  const [emailPreferences, setEmailPreferences] =
    useState<EmailPreferences | null>(null);
  const [twoFAEnabled, setTwoFAEnabled] = useState<boolean>(false);
  const [isSaving, setIsSaving] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [initialProfile, setInitialProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  // Password state for update
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isUpdatingPassword, setIsUpdatingPassword] = useState(false);
  const [pwMessage, setPwMessage] = useState<string | null>(null);
  const [pwError, setPwError] = useState<string | null>(null);

  // Password visibility toggles
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  // Deletion state
  const [deleteConfirmInput, setDeleteConfirmInput] = useState("");
  const [isDeleting, setIsDeleting] = useState(false);
  // Activity data (counts per day for last 30 days)
  const [activityCounts, setActivityCounts] = useState<number[] | null>(null);
  const [activityLabels, setActivityLabels] = useState<string[] | null>(null);
  const [isLoadingActivity, setIsLoadingActivity] = useState(false);
  const [recentActivities, setRecentActivities] = useState<Activity[] | null>(null);
  const [showRecentList, setShowRecentList] = useState(false);
  // Avatar visible URL (used for initial display and passed to uploader)
  const [profileAvatarUrl, setProfileAvatarUrl] = useState<string | null>(null);

  // memoize chart path generation to avoid recomputing on every render
  const chartMemo = useMemo(() => {
    if (!activityCounts) return null;
    const counts = activityCounts;
    const max = Math.max(...counts, 1);
    const step = 300 / Math.max(1, counts.length - 1);
    const points = counts.map((c, i) => {
      const x = i * step;
      const y = 100 - (c / max) * 80 - 10; // padding
      return `${x},${y}`;
    });
    const path = `M${points.join(" L ")}`;
    const areaPath = `${path} L 300,100 L 0,100 Z`;
    const dots = counts.map((c, i) => {
      const x = i * step;
      const y = 100 - (c / max) * 80 - 10;
      return { x, y };
    });
    return { path, areaPath, dots, max };
  }, [activityCounts]);

  // fetch activity (last N days). Accepts optional AbortSignal
  async function fetchActivity(userId?: string, signal?: AbortSignal) {
    if (!userId) return;
    setIsLoadingActivity(true);
    try {
      const res = await fetch(
        `/api/dashboard/activities?userId=${encodeURIComponent(userId)}`,
        { signal }
      );
      if (!res.ok) {
        console.warn("Failed to fetch activities", await res.text());
        setActivityCounts(null);
        return;
      }
      const json: ActivitiesApiResponse = await res.json();
      const activities: Activity[] = json.activities || [];
      setRecentActivities(activities.slice(0, 10));

      // compute counts for last 30 days
      const days = 30;
      const now = new Date();
      const counts = Array.from({ length: days }).map(() => 0);
      const labels: string[] = [];
      for (let i = days - 1; i >= 0; i--) {
        const d = new Date(now);
        d.setDate(now.getDate() - i);
        labels.push(
          d.toLocaleDateString(undefined, { month: "short", day: "numeric" })
        );
      }

      const start = new Date(now);
      start.setDate(now.getDate() - (days - 1));
      start.setHours(0, 0, 0, 0);

      activities.forEach((a) => {
        const t = new Date(a.timestamp);
        if (isNaN(t.getTime())) return;
        // if within range
        if (t >= start && t <= now) {
          const diffDays = Math.floor(
            (t.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)
          );
          if (diffDays >= 0 && diffDays < days) counts[diffDays]++;
        }
      });

      setActivityCounts(counts);
      setActivityLabels(labels);
    } catch (err: unknown) {
      const e = err as Error & { name?: string };
      if (e?.name === "AbortError") return;
      console.error("Error fetching activities", e);
      setActivityCounts(null);
    } finally {
      setIsLoadingActivity(false);
    }
  }

  // ActivitySection is imported from components/dashboard/activity-section

  useEffect(() => {
    // fetchActivity is now declared at top-level so we just call it with the controller.signal
    const controller = new AbortController();
    async function init() {
      const supabase = getSupabaseClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session?.user) {
        setIsLoading(false);
        return;
      }

      setUser(session.user);

      try {
        const res = await fetch(
          `/api/dashboard/profile?userId=${session.user.id}`
        );
        if (res.ok) {
          const json: ProfileApiResponse = await res.json();
          const p = json?.profile ?? null;
          // Read totp enabled state if provided by the API
          try {
            const totp = p?.totp || null;
            const totpEnabled = typeof totp === 'object' && totp !== null && 'enabled' in totp ? Boolean((totp as { enabled?: boolean }).enabled) : false;
            setTwoFAEnabled(Boolean(totpEnabled));
          } catch (e) {
            // ignore
          }
          setProfile({
            id: session.user.id,
            full_name: p?.full_name || "",
            username: p?.username || "",
            avatar_path: p?.avatar_path || null,
            avatar_url: p?.avatar_url ?? p?.avatar ?? null,
            avatar: p?.avatar ?? null,
            totp: p?.totp ?? null,
            trustedDevice: p?.trustedDevice ?? false,
          });
          const url = p?.avatar_url ?? p?.avatar ?? null;
          setProfileAvatarUrl(url);
          setInitialProfile({
            id: session.user.id,
            full_name: p?.full_name || "",
            username: p?.username || "",
            avatar_path: p?.avatar_path || null,
            avatar_url: p?.avatar_url ?? p?.avatar ?? null,
            avatar: p?.avatar ?? null,
            totp: p?.totp ?? null,
            trustedDevice: p?.trustedDevice ?? false,
          });
          try {
            fetchActivity(session.user.id, controller.signal);
          } catch (e) {
            /* ignore */
          }
        } else {
          console.error("Failed to load profile", await res.text());
        }
      } catch (err) {
        console.error("Error fetching profile", err);
      }

      setIsLoading(false);
    }

    init();

    return () => {
      // abort any in-flight requests started in init
      controller.abort();
    };
  }, []);

  // Open top-level modals based on query params AFTER we have the user loaded
  useEffect(() => {
    if (!user) return;
    try {
      const params = new URLSearchParams(window.location.search);
      const open2fa = params.get('open2fa');
      const openActivity = params.get('openActivity');
      if (openActivity === 'true' || openActivity === '1') {
        setShowRecentList(true);
      }
      if (open2fa === 'true' || open2fa === '1') {
        setShow2FAModal(true);
        // Request 2FA setup data (similar to pressing 'Enable')
        (async () => {
          try {
            setIsSettingUp2FA(true);
            const res = await fetch('/api/dashboard/2fa/setup', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ userId: user.id }),
            });
            if (!res.ok) {
              console.warn('Failed to setup 2FA via query param', await res.text());
              setIsSettingUp2FA(false);
              return;
            }
            const json = await res.json();
            setSetupData({ secret: json.secret, otpauth: json.otpauth, qrDataUrl: json.qrDataUrl });
          } catch (e) {
            console.warn('2FA setup via query param failed', e);
          } finally {
            setIsSettingUp2FA(false);
          }
        })();
      }
      if (open2fa || openActivity) {
        try {
          const url = new URL(window.location.href);
          url.searchParams.delete('open2fa');
          url.searchParams.delete('openActivity');
          window.history.replaceState({}, '', url.toString());
        } catch (e) {
          /* ignore */
        }
      }
    } catch (e) {
      /* ignore */
    }
  }, [user]);

  if (isLoading) {
    return null; // Loading state is handled by the layout
  }

  return (
    <>
      <div className="space-y-6">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Profile</h2>
          <p className="text-muted-foreground">
            Manage your account settings and preferences.
          </p>
        </div>

        <Separator />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Profile Information */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Personal Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center space-x-4">
                  <div>
                    <AvatarUploader
                      userId={user?.id}
                      displayName={profile?.username || user?.email || null}
                      initialAvatarUrl={profileAvatarUrl}
                      className="h-16 w-16"
                      onUpload={(publicUrl, path) => {
                        // Keep avatar_url for display and also update profile avatar_path
                        setProfileAvatarUrl(publicUrl || null);
                          setProfile((s: UserProfile | null) => ({
                          id: s?.id || user?.id || '',
                          ...(s || {}),
                          avatar_path: path || s?.avatar_path || null,
                        }));
                          setInitialProfile((s: UserProfile | null) => ({
                          id: s?.id || user?.id || '',
                          ...(s || {}),
                          avatar_path: path || s?.avatar_path || null,
                        }));
                      }}
                    />
                  </div>
                  <div>
                    <div className="text-sm font-medium">Avatar</div>
                    <div className="text-sm text-muted-foreground">
                      Click the avatar to upload a new image
                    </div>
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" value={user?.email || ""} disabled />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="name">Full Name</Label>
                  <Input
                    id="name"
                    placeholder="Enter your full name"
                    value={profile?.full_name ?? ""}
                    onChange={(e) =>
                      setProfile((s: UserProfile | null) => ({
                        id: s?.id || user?.id || '',
                        ...(s || {}),
                        full_name: e.target.value,
                      }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="username">Username</Label>
                  <Input
                    id="username"
                    placeholder="username"
                    value={profile?.username ?? ""}
                    onChange={(e) =>
                      setProfile((s: UserProfile | null) => ({
                        id: s?.id || user?.id || '',
                        ...(s || {}),
                        username: e.target.value,
                      }))
                    }
                  />
                </div>

                {/* Avatar URL is managed via the dashboard avatar upload flow; remove the manual URL input. */}

                <div>
                  <Button
                    className="w-full"
                    onClick={async () => {
                      setMessage(null);
                      setError(null);
                      if (!user) {
                        setError("No authenticated user");
                        return;
                      }

                      // avoid sending if nothing changed (shallow compare known fields)
                      const isUnchanged =
                        (profile?.full_name ?? "") ===
                          (initialProfile?.full_name ?? "") &&
                        (profile?.username ?? "") ===
                          (initialProfile?.username ?? "") &&
                        (profile?.avatar_path ?? null) ===
                          (initialProfile?.avatar_path ?? null);
                      if (isUnchanged) {
                        setMessage("No changes to save");
                        return;
                      }

                      setIsSaving(true);
                      try {
                        // Prefer sending avatar_path when available (server prefers path)
                        const bodyPayload: Record<string, any> = {
                          userId: user.id,
                        };
                        if (profile?.full_name !== undefined)
                          bodyPayload.full_name = profile.full_name;
                        if (profile?.username !== undefined)
                          bodyPayload.username = profile.username;
                        if (profile?.avatar_path)
                          bodyPayload.avatar_path = profile.avatar_path;

                        const res = await fetch("/api/dashboard/profile", {
                          method: "POST",
                          headers: { "Content-Type": "application/json" },
                          body: JSON.stringify(bodyPayload),
                        });

                        if (res.ok) {
                          const json = await res.json();
                          const updated = json?.profile || null;
                          setInitialProfile((s: UserProfile | null) => ({
                            id: s?.id || user?.id || '',
                            ...(s || {}),
                            full_name: updated?.full_name || profile?.full_name || "",
                            username: updated?.username || profile?.username || "",
                            avatar_path: updated?.avatar_path || profile?.avatar_path || null,
                          }));
                          setMessage("Profile updated");
                          // Broadcast profile update so other components (forum, etc.) can refresh
                          try {
                            const bc =
                              typeof window !== "undefined" &&
                              "BroadcastChannel" in window
                                ? new BroadcastChannel("profile-updates")
                                : null;
                            const payload = {
                              userId: user.id,
                              full_name:
                                updated?.full_name || profile?.full_name || "",
                              username:
                                updated?.username || profile?.username || "",
                              avatar: updated?.avatar || null,
                              avatar_url:
                                updated?.avatar_url || updated?.avatar || null,
                              avatar_path: updated?.avatar_path || null,
                            };
                            if (bc) {
                              bc.postMessage(payload);
                              bc.close();
                            }
                            try {
                              window.dispatchEvent(
                                new CustomEvent("profile:updated", {
                                  detail: payload,
                                })
                              );
                            } catch (e) {
                              /* ignore */
                            }
                          } catch (e) {
                            /* ignore broadcast failures */
                          }
                          try {
                            // Log activity
                            await fetch("/api/dashboard/activities", {
                              method: "POST",
                              headers: { "Content-Type": "application/json" },
                              body: JSON.stringify({
                                userId: user.id,
                                title: "Updated profile",
                                description: "User updated profile information",
                              }),
                            });
                          } catch (e) {
                            console.warn("Failed to log activity", e);
                          }
                        } else {
                          const txt = await res.text();
                          setError(`Update failed: ${txt}`);
                        }
                      } catch (err) {
                        console.error("Save profile error", err);
                        setError("Unexpected error while saving");
                      } finally {
                        setIsSaving(false);
                      }
                    }}
                    disabled={isSaving}
                  >
                    {isSaving ? "Saving…" : "Save Changes"}
                  </Button>

                  {message && (
                    <p className="text-sm text-green-600 mt-2">{message}</p>
                  )}
                  {error && (
                    <p className="text-sm text-destructive mt-2">{error}</p>
                  )}
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Security Settings */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Security</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="current-password">Current Password</Label>
                  <div className="relative">
                    <Input
                      id="current-password"
                      type={showCurrent ? "text" : "password"}
                      value={currentPassword}
                      onChange={(e) => setCurrentPassword(e.target.value)}
                    />
                    <button
                      type="button"
                      aria-label={
                        showCurrent
                          ? "Hide current password"
                          : "Show current password"
                      }
                      onClick={() => setShowCurrent((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showCurrent ? (
                        <EyeOffIcon className="h-5 w-5" />
                      ) : (
                        <EyeIcon className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="new-password">New Password</Label>
                  <div className="relative">
                    <Input
                      id="new-password"
                      type={showNew ? "text" : "password"}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                    />
                    <button
                      type="button"
                      aria-label={
                        showNew ? "Hide new password" : "Show new password"
                      }
                      onClick={() => setShowNew((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showNew ? (
                        <EyeOffIcon className="h-5 w-5" />
                      ) : (
                        <EyeIcon className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                  {/* <div className="text-sm text-muted-foreground">Password must be at least 8 characters and include letters, numbers, and a special character.</div> */}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="confirm-password">Confirm New Password</Label>
                  <div className="relative">
                    <Input
                      id="confirm-password"
                      type={showConfirm ? "text" : "password"}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                    />
                    <button
                      type="button"
                      aria-label={
                        showConfirm
                          ? "Hide confirm password"
                          : "Show confirm password"
                      }
                      onClick={() => setShowConfirm((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showConfirm ? (
                        <EyeOffIcon className="h-5 w-5" />
                      ) : (
                        <EyeIcon className="h-5 w-5" />
                      )}
                    </button>
                  </div>
                </div>

                <div>
                  <Button
                    className="w-full"
                    onClick={async () => {
                      setPwMessage(null);
                      setPwError(null);

                      if (!user) {
                        setPwError("No authenticated user");
                        return;
                      }

                      if (!newPassword) {
                        setPwError("Please enter a new password");
                        return;
                      }

                      if (newPassword !== confirmPassword) {
                        setPwError(
                          "New password and confirmation do not match"
                        );
                        return;
                      }

                      // Basic password strength check (length)
                      if (newPassword.length < 8) {
                        setPwError(
                          "Password must be at least 8 characters long"
                        );
                        return;
                      }

                      // Additional strength checks (upper/lower/number/special)
                      const strengthErrors: string[] = [];
                      if (!/[a-z]/.test(newPassword))
                        strengthErrors.push("one lowercase letter");
                      if (!/[A-Z]/.test(newPassword))
                        strengthErrors.push("one uppercase letter");
                      if (!/[0-9]/.test(newPassword))
                        strengthErrors.push("one number");
                      if (!/[^A-Za-z0-9]/.test(newPassword))
                        strengthErrors.push("one special character");
                      if (strengthErrors.length) {
                        setPwError(
                          `Password should include at least ${strengthErrors.slice(0, 2).join(", ")}${strengthErrors.length > 2 ? ", ..." : ""}`
                        );
                        return;
                      }

                      setIsUpdatingPassword(true);
                      try {
                        if (!currentPassword) {
                          setPwError("Please enter your current password");
                          setIsUpdatingPassword(false);
                          return;
                        }

                        if (!user.email) {
                          setPwError("No email available for current user");
                          setIsUpdatingPassword(false);
                          return;
                        }

                        try {
                          await authLogin(user.email, currentPassword);
                        } catch (err: unknown) {
                          const e = err as Error;
                          console.warn(
                            "Current password verification failed",
                            e
                          );
                          setPwError("Current password is incorrect");
                          setIsUpdatingPassword(false);
                          return;
                        }

                        // Perform password update for the current authenticated user
                        await authUpdatePassword(newPassword);
                        setPwMessage("Password updated");
                        toast.success("Password updated");
                        setCurrentPassword("");
                        setNewPassword("");
                        setConfirmPassword("");
                        try {
                          await fetch("/api/dashboard/activities", {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({
                              userId: user.id,
                              title: "Updated password",
                              description: "User changed their password",
                            }),
                          });
                        } catch (e) {
                          console.warn(
                            "Failed to log password update activity",
                            e
                          );
                        }
                      } catch (err: unknown) {
                        const e = err as Error & { message?: string };
                        console.error("Password update error", e);
                        setPwError(e?.message || "Failed to update password");
                      } finally {
                        setIsUpdatingPassword(false);
                      }
                    }}
                    disabled={isUpdatingPassword}
                  >
                    {isUpdatingPassword ? "Updating…" : "Update Password"}
                  </Button>

                  {pwMessage && (
                    <p className="text-sm text-green-600 mt-2">{pwMessage}</p>
                  )}
                  {pwError && (
                    <p className="text-sm text-destructive mt-2">{pwError}</p>
                  )}
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Activity Chart */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="md:col-span-2"
          >
            <Card>
              <CardHeader>
                <CardTitle>Login Activity</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="w-full">
                  <div className="flex items-start justify-between">
                    <div>
                      <div className="text-sm text-muted-foreground">
                        {isLoadingActivity ? "Loading activity…" : "Login activity over the past 30 days"}
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => {
                          if (user?.id) fetchActivity(user.id);
                        }}
                        aria-label="Refresh activity"
                      >
                        Refresh
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setShowRecentList((s) => !s)}
                        aria-pressed={showRecentList}
                      >
                        {showRecentList ? "Hide recent" : "Show recent"}
                      </Button>
                    </div>
                  </div>

                  <ActivitySection
                    counts={activityCounts}
                    labels={activityLabels}
                    isLoading={isLoadingActivity}
                    recentActivities={recentActivities}
                    showRecentList={showRecentList}
                    onRefresh={() => { if (user?.id) fetchActivity(user.id); }}
                    onToggleRecent={() => setShowRecentList(s => !s)}
                  />

                  <p className="text-sm text-muted-foreground mt-4">
                    This chart shows your login activity over the past 30 days.
                  </p>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Account Settings */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="md:col-span-2"
          >
            <Card>
              <CardHeader>
                <CardTitle>Account Settings</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Two-Factor Authentication</p>
                      <p className="text-sm text-muted-foreground">
                        Add an extra layer of security to your account
                      </p>
                    </div>
                    {twoFAEnabled ? (
                      <div className="flex items-center space-x-2">
                        <span className="text-sm text-green-600">Enabled</span>
                        <Button
                          variant="ghost"
                          onClick={async () => {
                            if (!user) {
                              toast.error("No authenticated user");
                              return;
                            }
                            try {
                              const res = await fetch(
                                "/api/dashboard/2fa/disable",
                                {
                                  method: "POST",
                                  headers: {
                                    "Content-Type": "application/json",
                                  },
                                  body: JSON.stringify({ userId: user.id }),
                                }
                              );
                              if (!res.ok) {
                                const txt = await res.text();
                                toast.error(`Failed to disable 2FA: ${txt}`);
                                return;
                              }
                              // remove trusted marker for safety
                              try {
                                window.localStorage.removeItem(
                                  `trusted_device_${user.id}`
                                );
                              } catch (e) {
                                /* ignore */
                              }
                              setTwoFAEnabled(false);
                              toast.success(
                                "Two-Factor Authentication disabled"
                              );
                            } catch (err) {
                              console.error("Disable 2FA error", err);
                              toast.error("Failed to disable 2FA");
                            }
                          }}
                        >
                          Disable
                        </Button>
                      </div>
                    ) : (
                      <div className="flex items-center space-x-2">
                        <Button
                          variant="outline"
                          onClick={async () => {
                            setTwoFAError(null);
                            if (!user) {
                              setTwoFAError("No authenticated user");
                              return;
                            }
                            setIsSettingUp2FA(true);
                            try {
                              const res = await fetch(
                                "/api/dashboard/2fa/setup",
                                {
                                  method: "POST",
                                  headers: {
                                    "Content-Type": "application/json",
                                  },
                                  body: JSON.stringify({ userId: user.id }),
                                }
                              );
                              if (!res.ok) {
                                const txt = await res.text();
                                setTwoFAError(`Setup failed: ${txt}`);
                                return;
                              }
                              const json = await res.json();
                              setSetupData({
                                secret: json.secret,
                                otpauth: json.otpauth,
                                qrDataUrl: json.qrDataUrl,
                              });
                              setShow2FAModal(true);
                              // if this was flagged as a new device, keep prompt state until verified
                              // nothing else here
                            } catch (err) {
                              console.error("2FA setup error", err);
                              setTwoFAError("Failed to start 2FA setup");
                            } finally {
                              setIsSettingUp2FA(false);
                            }
                          }}
                        >
                          {isSettingUp2FA ? "Preparing…" : "Enable"}
                        </Button>
                        {twoFAError && (
                          <p className="text-sm text-destructive">
                            {twoFAError}
                          </p>
                        )}
                      </div>
                    )}
                  </div>
                  {/* If this appears to be a new device, gently encourage enabling 2FA */}

                  <Separator />

                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Email Notifications</p>
                      <p className="text-sm text-muted-foreground">
                        Receive email notifications about account activity
                      </p>
                    </div>
                    <div>
                      <Button
                        variant="outline"
                        onClick={async () => {
                          // open modal and load current preference (store full preferences so we can merge)
                          setShowEmailSettingsModal(true);
                          try {
                            if (!user) return;
                            const res = await fetch(
                              `/api/dashboard/settings?userId=${encodeURIComponent(user.id)}`
                            );
                            if (!res.ok) {
                              console.warn(
                                "Failed to fetch settings",
                                await res.text()
                              );
                              setEmailNotificationsEnabled(false);
                              setEmailPreferences({});
                              return;
                            }
                            const json = await res.json();
                            const prefs = json?.preferences || {};
                            setEmailPreferences(prefs || {});
                            setEmailNotificationsEnabled(
                              Boolean(prefs?.emailNotifications)
                            );
                          } catch (e) {
                            console.error("Error loading settings", e);
                            setEmailNotificationsEnabled(false);
                            setEmailPreferences({});
                          }
                        }}
                      >
                        Configure
                      </Button>
                    </div>
                  </div>

                  <Modal
                    open={showEmailSettingsModal}
                    onClose={() => {
                      if (!isSavingEmailSettings) {
                        setShowEmailSettingsModal(false);
                      }
                    }}
                    ariaLabel="Email notification settings"
                  >
                    <div className="space-y-4 max-w-md">
                      <h3 className="text-lg font-semibold">
                        Email notifications
                      </h3>
                      <p className="text-sm text-muted-foreground">
                        Choose whether to receive email alerts about important
                        account activity.
                      </p>

                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Account activity emails</p>
                          <p className="text-sm text-muted-foreground">
                            Sign-in alerts and security notifications
                          </p>
                        </div>
                        <div>
                          <Switch
                            checked={!!emailNotificationsEnabled}
                            onCheckedChange={(v: boolean) =>
                              setEmailNotificationsEnabled(v)
                            }
                          />
                        </div>
                      </div>

                      <div className="flex items-center justify-end space-x-2">
                        <Button
                          variant="ghost"
                          onClick={() => setShowEmailSettingsModal(false)}
                          disabled={isSavingEmailSettings}
                        >
                          Cancel
                        </Button>
                        <Button
                          onClick={async () => {
                            if (!user) return;
                            setIsSavingEmailSettings(true);
                            try {
                              const merged = {
                                ...(emailPreferences || {}),
                                emailNotifications: !!emailNotificationsEnabled,
                              };
                              const res = await fetch(
                                "/api/dashboard/settings",
                                {
                                  method: "POST",
                                  headers: {
                                    "Content-Type": "application/json",
                                  },
                                  body: JSON.stringify({
                                    userId: user.id,
                                    preferences: merged,
                                  }),
                                }
                              );
                              if (!res.ok) {
                                const txt = await res.text();
                                toast.error(`Failed to save settings: ${txt}`);
                                return;
                              }
                              toast.success("Settings saved");
                              setShowEmailSettingsModal(false);
                            } catch (e) {
                              console.error("Save settings error", e);
                              toast.error("Failed to save settings");
                            } finally {
                              setIsSavingEmailSettings(false);
                            }
                          }}
                          disabled={isSavingEmailSettings}
                        >
                          {isSavingEmailSettings ? "Saving…" : "Save"}
                        </Button>
                      </div>
                    </div>
                  </Modal>

                  <Separator />

                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-destructive">
                        Delete Account
                      </p>
                      <p className="text-sm text-muted-foreground">
                        Permanently delete your account and all data
                      </p>
                    </div>
                    <>
                      <Button
                        variant="destructive"
                        onClick={() => setShowDeleteModal(true)}
                      >
                        Delete Account
                      </Button>

                      <Modal
                        open={showDeleteModal}
                        onClose={() => {
                          if (!isDeleting) {
                            setShowDeleteModal(false);
                            setDeleteConfirmInput("");
                          }
                        }}
                        ariaLabel="Confirm account deletion"
                      >
                        <div className="space-y-4">
                          <h3 className="text-lg font-semibold">
                            Delete account
                          </h3>
                          <p className="text-sm text-muted-foreground">
                            This will permanently delete your account and all
                            associated data. This action cannot be undone.
                          </p>

                          <div className="text-sm">
                            <p>
                              To confirm, type your email address{" "}
                              <strong>{user?.email}</strong> below and click{" "}
                              <em>Delete account</em>.
                            </p>
                          </div>

                          <Input
                            placeholder={user?.email || "Your email"}
                            value={deleteConfirmInput}
                            onChange={(e) =>
                              setDeleteConfirmInput(e.target.value)
                            }
                          />

                          <div className="flex items-center justify-end space-x-2">
                            <Button
                              variant="ghost"
                              onClick={() => {
                                if (!isDeleting) {
                                  setShowDeleteModal(false);
                                  setDeleteConfirmInput("");
                                }
                              }}
                              disabled={isDeleting}
                            >
                              Cancel
                            </Button>
                            <Button
                              variant="destructive"
                              onClick={async () => {
                                if (!user) {
                                  toast.error("No authenticated user");
                                  return;
                                }
                                if (
                                  deleteConfirmInput.trim() !==
                                  (user.email || "")
                                ) {
                                  toast.error(
                                    "Confirmation text does not match your email"
                                  );
                                  return;
                                }

                                setIsDeleting(true);
                                try {
                                  const res = await fetch(
                                    "/api/dashboard/delete-account",
                                    {
                                      method: "POST",
                                      headers: {
                                        "Content-Type": "application/json",
                                      },
                                      credentials: "same-origin",
                                      body: JSON.stringify({ userId: user.id }),
                                    }
                                  );

                                  if (!res.ok) {
                                    const txt = await res.text();
                                    toast.error(`Delete failed: ${txt}`);
                                    setIsDeleting(false);
                                    return;
                                  }

                                  toast.success("Account deleted");
                                  try {
                                    await getSupabaseClient().auth.signOut();
                                  } catch (e) {
                                    /* ignore */
                                  }
                                  window.location.href = "/";
                                } catch (err) {
                                  console.error("Delete account error", err);
                                  toast.error("Failed to delete account");
                                } finally {
                                  setIsDeleting(false);
                                }
                              }}
                              disabled={
                                isDeleting ||
                                deleteConfirmInput.trim() !==
                                  (user?.email || "")
                              }
                            >
                              {isDeleting ? "Deleting…" : "Delete account"}
                            </Button>
                          </div>
                        </div>
                      </Modal>

                      {/* 2FA Setup / Verify Modal */}
                      <Modal
                        open={show2FAModal}
                        onClose={() => {
                          if (!isVerifying2FA) {
                            setShow2FAModal(false);
                            setSetupData(null);
                            setVerifyToken("");
                          }
                        }}
                        ariaLabel="Two-Factor Authentication setup"
                      >
                        <div className="space-y-5 text-card-foreground">
                          <div className="flex items-start gap-3">
                            <div className="mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-md border bg-muted">
                              <ShieldCheck
                                className="h-5 w-5 text-primary"
                                aria-hidden="true"
                              />
                            </div>
                            <div className="space-y-1">
                              <h3 className="text-lg font-semibold">
                                Set up Two-Factor Authentication
                              </h3>
                              <p className="text-sm text-muted-foreground">
                                Scan the QR code with your authenticator app,
                                or enter the manual secret, then verify the
                                generated code.
                              </p>
                            </div>
                          </div>

                          {setupData?.qrDataUrl ? (
                            <div className="rounded-md border bg-muted/40 p-4">
                              <div className="mx-auto flex h-56 w-56 max-w-full items-center justify-center rounded-md border bg-white p-4">
                                {/* eslint-disable-next-line @next/next/no-img-element */}
                                <SafeImage
                                  src={setupData.qrDataUrl}
                                  alt="2FA QR code"
                                  className="h-full w-full object-contain"
                                />
                              </div>
                            </div>
                          ) : (
                            <div className="rounded-md border bg-muted/40 p-4 text-sm text-muted-foreground">
                              No QR available; use the manual secret
                            </div>
                          )}

                          <div className="space-y-2">
                            <Label htmlFor="totp-secret">Manual secret</Label>
                            <div className="flex min-w-0 items-center gap-2">
                              <Input
                                id="totp-secret"
                                value={setupData?.secret || ""}
                                readOnly
                                className="min-w-0 font-mono text-xs tracking-wide"
                              />
                              <Button
                                type="button"
                                variant="outline"
                                size="icon"
                                aria-label="Copy manual secret"
                                title="Copy manual secret"
                                onClick={() => {
                                  if (setupData?.secret) {
                                    navigator.clipboard?.writeText(
                                      setupData.secret
                                    );
                                    toast.success("Secret copied");
                                  }
                                }}
                              >
                                <Copy className="h-4 w-4" aria-hidden="true" />
                              </Button>
                            </div>
                          </div>

                          <div className="space-y-2">
                            <Label htmlFor="totp-setup-code">
                              Authenticator code
                            </Label>
                            <Input
                              id="totp-setup-code"
                              placeholder="123456"
                              value={verifyToken}
                              onChange={(e) =>
                                setVerifyToken(
                                  e.target.value.replace(/\D/g, "").slice(0, 8)
                                )
                              }
                              onKeyDown={(e) => {
                                if (e.key === "Enter") {
                                  e.preventDefault();
                                  verify2FAButtonRef.current?.click();
                                }
                              }}
                              inputMode="numeric"
                              autoComplete="one-time-code"
                              pattern="[0-9]*"
                              maxLength={8}
                              className="text-center text-lg tracking-widest"
                            />
                          </div>

                          {twoFAError && (
                            <Alert variant="destructive">
                              <AlertDescription>{twoFAError}</AlertDescription>
                            </Alert>
                          )}

                          <div className="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                            <Button
                              variant="ghost"
                              onClick={() => {
                                if (!isVerifying2FA) {
                                  setShow2FAModal(false);
                                  setSetupData(null);
                                  setVerifyToken("");
                                }
                              }}
                              disabled={isVerifying2FA}
                            >
                              Cancel
                            </Button>
                            <Button
                              ref={verify2FAButtonRef}
                              onClick={async () => {
                                if (!user) {
                                  setTwoFAError("No authenticated user");
                                  return;
                                }
                                if (!setupData?.secret) {
                                  setTwoFAError("Missing secret to verify");
                                  return;
                                }
                                if (
                                  !verifyToken ||
                                  !/^[0-9]{6,8}$/.test(verifyToken.trim())
                                ) {
                                  setTwoFAError(
                                    "Please enter a valid code from your authenticator app"
                                  );
                                  return;
                                }

                                setTwoFAError(null);
                                setIsVerifying2FA(true);
                                try {
                                  const res = await fetch(
                                    "/api/dashboard/2fa/verify",
                                    {
                                      method: "POST",
                                      headers: {
                                        "Content-Type": "application/json",
                                      },
                                      body: JSON.stringify({
                                        userId: user.id,
                                        secret: setupData.secret,
                                        token: verifyToken.trim(),
                                      }),
                                    }
                                  );
                                  if (!res.ok) {
                                    const txt = await res.text();
                                    setTwoFAError(
                                      `Verification failed: ${txt}`
                                    );
                                    return;
                                  }
                                  const json = await res.json();
                                  if (json?.success) {
                                    setTwoFAEnabled(true);
                                    toast.success(
                                      "Two-Factor Authentication enabled"
                                    );
                                    setShow2FAModal(false);
                                    setSetupData(null);
                                    setVerifyToken("");
                                    try {
                                      await fetch("/api/dashboard/activities", {
                                        method: "POST",
                                        headers: {
                                          "Content-Type": "application/json",
                                        },
                                        body: JSON.stringify({
                                          userId: user.id,
                                          title: "Enabled 2FA",
                                          description:
                                            "User enabled two-factor authentication",
                                        }),
                                      });
                                    } catch (e) {
                                      console.warn(
                                        "Failed to log 2FA enable activity",
                                        e
                                      );
                                    }
                                  } else if (json?.error) {
                                    setTwoFAError(
                                      json.error || "Verification failed"
                                    );
                                  } else {
                                    // handle server warning (preferences missing)
                                    if (json?.warning) {
                                      setTwoFAError(
                                        String(json.warning) ||
                                          "Two-Factor Authentication could not be persisted"
                                      );
                                    } else {
                                      setTwoFAError(
                                        "Verification response unexpected"
                                      );
                                    }
                                  }
                                } catch (err) {
                                  console.error("2FA verify error", err);
                                  setTwoFAError("Verification failed");
                                } finally {
                                  setIsVerifying2FA(false);
                                }
                              }}
                              disabled={isVerifying2FA}
                            >
                              {isVerifying2FA
                                ? "Verifying…"
                                : "Verify & Enable"}
                            </Button>
                          </div>
                        </div>
                      </Modal>
                    </>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </>
  );
}
