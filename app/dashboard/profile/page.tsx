'use client';

import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Separator } from '@/components/ui/separator';
import { useState, useEffect, useMemo } from 'react';
import { toast } from 'sonner';
import { createClient } from '@/utils/supabase/client';
import { login as authLogin, updatePassword as authUpdatePassword } from '@/lib/utils/auth-helpers';
import { User } from '@supabase/supabase-js';
import { motion } from 'framer-motion';
import { PlaceholderChart } from '@/components/dashboard/placeholder-chart';
import ActivityChart from '@/components/dashboard/activity-chart';
import Modal from '@/components/ui/modal';

type Profile = {
  full_name?: string;
  username?: string;
  avatar_path?: string | null;
  // optional totp info if backend exposes it
  totp?: { enabled?: boolean } | null;
};

type Activity = {
  timestamp: string;
};

type TrustedDevice = {
  id: string;
  name?: string | null;
  user_agent?: string | null;
  last_seen?: string | null;
};

type EmailPreferences = Record<string, any>;

export default function ProfilePage() {
  const supabase = createClient();
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const [profile, setProfile] = useState<Profile | null>(null);
  const [initialProfile, setInitialProfile] = useState<Profile | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isUpdatingPassword, setIsUpdatingPassword] = useState(false);
  const [pwMessage, setPwMessage] = useState<string | null>(null);
  const [pwError, setPwError] = useState<string | null>(null);
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [deleteConfirmInput, setDeleteConfirmInput] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);
  // 2FA state
  const [twoFAEnabled, setTwoFAEnabled] = useState<boolean>(false);
  const [isNewDevice, setIsNewDevice] = useState<boolean>(false);
  const [show2FAModal, setShow2FAModal] = useState(false);
  const [isSettingUp2FA, setIsSettingUp2FA] = useState(false);
  const [setupData, setSetupData] = useState<{ secret?: string; otpauth?: string; qrDataUrl?: string } | null>(null);
  const [verifyToken, setVerifyToken] = useState('');
  const [isVerifying2FA, setIsVerifying2FA] = useState(false);
  const [twoFAError, setTwoFAError] = useState<string | null>(null);
  const [trustedDevices, setTrustedDevices] = useState<TrustedDevice[]>([]);
  const [isLoadingDevices, setIsLoadingDevices] = useState(false);
  // Email notifications settings
  const [showEmailSettingsModal, setShowEmailSettingsModal] = useState(false);
  const [emailNotificationsEnabled, setEmailNotificationsEnabled] = useState<boolean | null>(null);
  const [isSavingEmailSettings, setIsSavingEmailSettings] = useState(false);
  const [emailPreferences, setEmailPreferences] = useState<EmailPreferences | null>(null);
  // Activity data (counts per day for last 30 days)
  const [activityCounts, setActivityCounts] = useState<number[] | null>(null);
  const [activityLabels, setActivityLabels] = useState<string[] | null>(null);
  const [isLoadingActivity, setIsLoadingActivity] = useState(false);

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
    const path = `M${points.join(' L ')}`;
    const areaPath = `${path} L 300,100 L 0,100 Z`;
    const dots = counts.map((c, i) => {
      const x = i * step;
      const y = 100 - (c / max) * 80 - 10;
      return { x, y };
    });
    return { path, areaPath, dots, max };
  }, [activityCounts]);

  // fetch trusted devices; accepts optional AbortSignal to cancel when component unmounts
  async function fetchTrustedDevices(userId?: string, signal?: AbortSignal) {
    if (!userId) return;
    setIsLoadingDevices(true);
    try {
      const res = await fetch(`/api/dashboard/trusted-devices?userId=${userId}`, { signal });
      if (!res.ok) {
        console.warn('Failed to fetch trusted devices', await res.text());
        setTrustedDevices([]);
        return;
      }
      const json = await res.json();
      setTrustedDevices(json.devices || []);
    } catch (e: any) {
      if (e.name === 'AbortError') {
        // request was aborted, ignore
        return;
      }
      console.error('Error fetching trusted devices', e);
      setTrustedDevices([]);
    } finally {
      setIsLoadingDevices(false);
    }
  }

  // fetch activity (last N days). Accepts optional AbortSignal
  async function fetchActivity(userId?: string, signal?: AbortSignal) {
    if (!userId) return;
    setIsLoadingActivity(true);
    try {
      const res = await fetch(`/api/dashboard/activities?userId=${encodeURIComponent(userId)}`, { signal });
      if (!res.ok) {
        console.warn('Failed to fetch activities', await res.text());
        setActivityCounts(null);
        return;
      }
      const json = await res.json();
      const activities: Activity[] = json.activities || [];

      // compute counts for last 30 days
      const days = 30;
      const now = new Date();
      const counts = Array.from({ length: days }).map(() => 0);
      const labels: string[] = [];
      for (let i = days - 1; i >= 0; i--) {
        const d = new Date(now);
        d.setDate(now.getDate() - i);
        labels.push(d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }));
      }

      const start = new Date(now);
      start.setDate(now.getDate() - (days - 1));
      start.setHours(0, 0, 0, 0);

      activities.forEach((a) => {
        const t = new Date(a.timestamp);
        if (isNaN(t.getTime())) return;
        // if within range
        if (t >= start && t <= now) {
          const diffDays = Math.floor((t.getTime() - start.getTime()) / (1000 * 60 * 60 * 24));
          if (diffDays >= 0 && diffDays < days) counts[diffDays]++;
        }
      });

      setActivityCounts(counts);
      setActivityLabels(labels);
    } catch (e: any) {
      if (e.name === 'AbortError') return;
      console.error('Error fetching activities', e);
      setActivityCounts(null);
    } finally {
      setIsLoadingActivity(false);
    }
  }

  useEffect(() => {
    // fetchActivity is now declared at top-level so we just call it with the controller.signal
    const controller = new AbortController();
    async function init() {
      const supabase = createClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session?.user) {
        setIsLoading(false);
        return;
      }

      setUser(session.user);

      try {
        const res = await fetch(`/api/dashboard/profile?userId=${session.user.id}`);
        if (res.ok) {
          const json = await res.json();
          const p = json?.profile || {};
          // Read totp enabled state if provided by the API
          try {
            const totp = p?.totp || null;
            setTwoFAEnabled(Boolean(totp?.enabled));
          } catch (e) {
            // ignore
          }
          setProfile({
            full_name: p?.full_name || '',
            username: p?.username || '',
            avatar_path: p?.avatar_path || null,
          });
          setInitialProfile({
            full_name: p?.full_name || '',
            username: p?.username || '',
            avatar_path: p?.avatar_path || null,
          });
          // fetch server-side trusted devices list
            // fetch server-side trusted devices list and activity chart (abortable)
            try { fetchTrustedDevices(session.user.id, controller.signal); } catch (e) { /* ignore */ }
            try { fetchActivity(session.user.id, controller.signal); } catch (e) { /* ignore */ }
          // detect new device by checking a localStorage marker; if missing, prompt user
          try {
            const key = `trusted_device_${session.user.id}`;
            const trusted = typeof window !== 'undefined' ? window.localStorage.getItem(key) : null;
            if (!trusted) setIsNewDevice(true);
          } catch (e) {
            // ignore storage errors
          }
        } else {
          console.error('Failed to load profile', await res.text());
        }
      } catch (err) {
        console.error('Error fetching profile', err);
      }

      setIsLoading(false);
    }

    init();

    return () => {
      // abort any in-flight requests started in init
      controller.abort();
    };
  }, []);

  if (isLoading) {
    return null; // Loading state is handled by the layout
  }

  return (
    <DashboardLayout>
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
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" value={user?.email || ''} disabled />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="name">Full Name</Label>
                  <Input
                    id="name"
                    placeholder="Enter your full name"
                    value={profile?.full_name ?? ''}
                    onChange={(e) => setProfile((s) => ({ ...(s || {}), full_name: e.target.value }))}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="username">Username</Label>
                  <Input
                    id="username"
                    placeholder="username"
                    value={profile?.username ?? ''}
                    onChange={(e) => setProfile((s) => ({ ...(s || {}), username: e.target.value }))}
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
                        setError('No authenticated user');
                        return;
                      }

                      // avoid sending if nothing changed (shallow compare known fields)
                      const isUnchanged = (profile?.full_name ?? '') === (initialProfile?.full_name ?? '')
                        && (profile?.username ?? '') === (initialProfile?.username ?? '')
                        && (profile?.avatar_path ?? null) === (initialProfile?.avatar_path ?? null);
                      if (isUnchanged) {
                        setMessage('No changes to save');
                        return;
                      }

                        setIsSaving(true);
                      try {
                        // Prefer sending avatar_path when available (server prefers path)
                        const bodyPayload: Record<string, any> = { userId: user.id };
                        if (profile?.full_name !== undefined) bodyPayload.full_name = profile.full_name;
                        if (profile?.username !== undefined) bodyPayload.username = profile.username;
                        if (profile?.avatar_path) bodyPayload.avatar_path = profile.avatar_path;

                        const res = await fetch('/api/dashboard/profile', {
                          method: 'POST',
                          headers: { 'Content-Type': 'application/json' },
                          body: JSON.stringify(bodyPayload),
                        });

                        if (res.ok) {
                          const json = await res.json();
                          const updated = json?.profile || null;
                          setInitialProfile({
                            full_name: updated?.full_name || profile?.full_name || '',
                            username: updated?.username || profile?.username || '',
                            avatar_path: updated?.avatar_path || profile?.avatar_path || null,
                          });
                          setMessage('Profile updated');
                          try {
                            // Log activity
                            await fetch('/api/dashboard/activities', {
                              method: 'POST',
                              headers: { 'Content-Type': 'application/json' },
                              body: JSON.stringify({ userId: user.id, title: 'Updated profile', description: 'User updated profile information' }),
                            });
                          } catch (e) {
                            console.warn('Failed to log activity', e);
                          }
                        } else {
                          const txt = await res.text();
                          setError(`Update failed: ${txt}`);
                        }
                      } catch (err) {
                        console.error('Save profile error', err);
                        setError('Unexpected error while saving');
                      } finally {
                        setIsSaving(false);
                      }
                    }}
                    disabled={isSaving}
                  >
                    {isSaving ? 'Saving…' : 'Save Changes'}
                  </Button>

                  {message && <p className="text-sm text-green-600 mt-2">{message}</p>}
                  {error && <p className="text-sm text-destructive mt-2">{error}</p>}
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
                    <Input id="current-password" type={showCurrent ? 'text' : 'password'} value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} />
                    <button
                      type="button"
                      aria-label={showCurrent ? 'Hide current password' : 'Show current password'}
                      onClick={() => setShowCurrent((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showCurrent ? '🙈' : '👁️'}
                    </button>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="new-password">New Password</Label>
                  <div className="relative">
                    <Input id="new-password" type={showNew ? 'text' : 'password'} value={newPassword} onChange={(e) => setNewPassword(e.target.value)} />
                    <button
                      type="button"
                      aria-label={showNew ? 'Hide new password' : 'Show new password'}
                      onClick={() => setShowNew((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showNew ? '🙈' : '👁️'}
                    </button>
                  </div>
                  <div className="text-sm text-muted-foreground">Password must be at least 8 characters and include letters, numbers, and a special character.</div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="confirm-password">Confirm New Password</Label>
                  <div className="relative">
                    <Input id="confirm-password" type={showConfirm ? 'text' : 'password'} value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} />
                    <button
                      type="button"
                      aria-label={showConfirm ? 'Hide confirm password' : 'Show confirm password'}
                      onClick={() => setShowConfirm((s) => !s)}
                      className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
                    >
                      {showConfirm ? '🙈' : '👁️'}
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
                        setPwError('No authenticated user');
                        return;
                      }

                      if (!newPassword) {
                        setPwError('Please enter a new password');
                        return;
                      }

                      if (newPassword !== confirmPassword) {
                        setPwError('New password and confirmation do not match');
                        return;
                      }

                      // Basic password strength check (length)
                      if (newPassword.length < 8) {
                        setPwError('Password must be at least 8 characters long');
                        return;
                      }

                      // Additional strength checks (upper/lower/number/special)
                      const strengthErrors: string[] = [];
                      if (!/[a-z]/.test(newPassword)) strengthErrors.push('one lowercase letter');
                      if (!/[A-Z]/.test(newPassword)) strengthErrors.push('one uppercase letter');
                      if (!/[0-9]/.test(newPassword)) strengthErrors.push('one number');
                      if (!/[^A-Za-z0-9]/.test(newPassword)) strengthErrors.push('one special character');
                      if (strengthErrors.length) {
                        setPwError(`Password should include at least ${strengthErrors.slice(0, 2).join(', ')}${strengthErrors.length > 2 ? ', ...' : ''}`);
                        return;
                      }

                      setIsUpdatingPassword(true);
                      try {
                        // If user provided current password, verify it by attempting sign-in.
                        if (currentPassword) {
                          if (!user.email) {
                            setPwError('No email available for current user');
                            setIsUpdatingPassword(false);
                            return;
                          }
                          try {
                            await authLogin(user.email, currentPassword);
                          } catch (e: any) {
                            console.warn('Current password verification failed', e);
                            setPwError('Current password is incorrect');
                            setIsUpdatingPassword(false);
                            return;
                          }
                        }

                        // Perform password update for the current authenticated user
                        await authUpdatePassword(newPassword);
                        setPwMessage('Password updated');
                        toast.success('Password updated');
                        setCurrentPassword('');
                        setNewPassword('');
                        setConfirmPassword('');
                        try {
                          await fetch('/api/dashboard/activities', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ userId: user.id, title: 'Updated password', description: 'User changed their password' }),
                          });
                        } catch (e) {
                          console.warn('Failed to log password update activity', e);
                        }
                      } catch (e: any) {
                        console.error('Password update error', e);
                        setPwError(e?.message || 'Failed to update password');
                      } finally {
                        setIsUpdatingPassword(false);
                      }
                    }}
                    disabled={isUpdatingPassword}
                  >
                    {isUpdatingPassword ? 'Updating…' : 'Update Password'}
                  </Button>

                  {pwMessage && <p className="text-sm text-green-600 mt-2">{pwMessage}</p>}
                  {pwError && <p className="text-sm text-destructive mt-2">{pwError}</p>}
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
                  {isLoadingActivity ? (
                    <div className="text-sm text-muted-foreground">Loading activity…</div>
                  ) : activityCounts && activityLabels ? (
                    <div>
                      {/* Simple sparkline-style area chart built with SVG */}
                      <div className="w-full h-48">
                        <ActivityChart counts={activityCounts!} labels={activityLabels} height={160} showDotsInterval={6} />
                      </div>

                      <div className="mt-3 grid grid-cols-3 gap-2 text-xs text-muted-foreground">
                        <div>
                          <div className="font-medium">Total</div>
                          <div>{activityCounts.reduce((a, b) => a + b, 0)}</div>
                        </div>
                        <div>
                          <div className="font-medium">Period</div>
                          <div>Last 30 days</div>
                        </div>
                        <div>
                          <div className="font-medium">Peak</div>
                          <div>{Math.max(...activityCounts)}</div>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="text-sm text-muted-foreground">No activity data available.</div>
                  )}

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
                                toast.error('No authenticated user');
                                return;
                              }
                              try {
                                const res = await fetch('/api/dashboard/2fa/disable', {
                                  method: 'POST',
                                  headers: { 'Content-Type': 'application/json' },
                                  body: JSON.stringify({ userId: user.id }),
                                });
                                if (!res.ok) {
                                  const txt = await res.text();
                                  toast.error(`Failed to disable 2FA: ${txt}`);
                                  return;
                                }
                                // remove trusted marker for safety
                                try { window.localStorage.removeItem(`trusted_device_${user.id}`); } catch (e) { /* ignore */ }
                                setTwoFAEnabled(false);
                                toast.success('Two-Factor Authentication disabled');
                              } catch (err) {
                                console.error('Disable 2FA error', err);
                                toast.error('Failed to disable 2FA');
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
                              setTwoFAError('No authenticated user');
                              return;
                            }
                            setIsSettingUp2FA(true);
                            try {
                              const res = await fetch('/api/dashboard/2fa/setup', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ userId: user.id }),
                              });
                              if (!res.ok) {
                                const txt = await res.text();
                                setTwoFAError(`Setup failed: ${txt}`);
                                return;
                              }
                              const json = await res.json();
                              setSetupData({ secret: json.secret, otpauth: json.otpauth, qrDataUrl: json.qrDataUrl });
                              setShow2FAModal(true);
                              // if this was flagged as a new device, keep prompt state until verified
                              // nothing else here
                            } catch (err) {
                              console.error('2FA setup error', err);
                              setTwoFAError('Failed to start 2FA setup');
                            } finally {
                              setIsSettingUp2FA(false);
                            }
                          }}
                        >
                          {isSettingUp2FA ? 'Preparing…' : 'Enable'}
                        </Button>
                        {twoFAError && <p className="text-sm text-destructive">{twoFAError}</p>}
                      </div>
                    )}
                  </div>
                  {/* If this appears to be a new device, gently encourage enabling 2FA */}
                  {isNewDevice && !twoFAEnabled && (
                    <div className="mt-3 p-3 border rounded bg-yellow-50 text-sm flex items-center justify-between">
                      <div>
                        <strong>New device detected.</strong>
                        <div className="text-muted-foreground">For extra security, consider enabling Two-Factor Authentication.</div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Button
                          variant="ghost"
                          onClick={() => {
                            // mark device as trusted to stop prompting
                            try { if (user) window.localStorage.setItem(`trusted_device_${user.id}`, '1'); } catch (e) { /* ignore */ }
                            setIsNewDevice(false);
                            toast.success('This device is now trusted');
                          }}
                        >
                          Trust this device
                        </Button>
                        <Button
                          onClick={async () => {
                            // open 2FA setup flow
                            if (!user) return;
                            setTwoFAError(null);
                            setIsSettingUp2FA(true);
                            try {
                              const res = await fetch('/api/dashboard/2fa/setup', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ userId: user.id }),
                              });
                              if (!res.ok) {
                                const txt = await res.text();
                                setTwoFAError(`Setup failed: ${txt}`);
                                return;
                              }
                              const json = await res.json();
                              setSetupData({ secret: json.secret, otpauth: json.otpauth, qrDataUrl: json.qrDataUrl });
                              setShow2FAModal(true);
                            } catch (err) {
                              console.error('2FA setup error', err);
                              setTwoFAError('Failed to start 2FA setup');
                            } finally {
                              setIsSettingUp2FA(false);
                            }
                          }}
                        >
                          Enable 2FA
                        </Button>
                      </div>
                    </div>
                  )}

                  <Separator />

                  <div>
                    <p className="font-medium">Trusted Devices</p>
                    <p className="text-sm text-muted-foreground">Devices you've marked as trusted (you can revoke access per device).</p>
                    <div className="mt-3 space-y-2">
                      {isLoadingDevices ? (
                        <div className="text-sm text-muted-foreground">Loading devices…</div>
                      ) : trustedDevices.length === 0 ? (
                        <div className="text-sm text-muted-foreground">No trusted devices found.</div>
                      ) : (
                        trustedDevices.map((d: TrustedDevice) => (
                          <div key={d.id} className="flex items-center justify-between p-2 border rounded">
                            <div className="text-sm">
                              <div className="font-medium">{d.name || 'Unnamed device'}</div>
                              <div className="text-xs text-muted-foreground">{d.user_agent || 'Unknown'}</div>
                              <div className="text-xs text-muted-foreground">Last seen: {d.last_seen ? new Date(d.last_seen).toLocaleString() : '—'}</div>
                            </div>
                            <div>
                              <Button
                                variant="ghost"
                                onClick={async () => {
                                  if (!user) return;
                                  try {
                                    const res = await fetch('/api/dashboard/trusted-devices/revoke', {
                                      method: 'POST',
                                      headers: { 'Content-Type': 'application/json' },
                                      body: JSON.stringify({ userId: user.id, id: d.id }),
                                    });
                                    if (!res.ok) {
                                      const txt = await res.text();
                                      toast.error(`Failed to revoke device: ${txt}`);
                                      return;
                                    }
                                    toast.success('Device revoked');
                                    fetchTrustedDevices(user.id);
                                  } catch (e) {
                                    console.error('Revoke device error', e);
                                    toast.error('Failed to revoke device');
                                  }
                                }}
                              >
                                Revoke
                              </Button>
                            </div>
                          </div>
                        ))
                      )}
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Email Notifications</p>
                      <p className="text-sm text-muted-foreground">
                        Receive email notifications about account activity
                      </p>
                    </div>
                    <div>
                      <Button variant="outline" onClick={async () => {
                        // open modal and load current preference (store full preferences so we can merge)
                        setShowEmailSettingsModal(true);
                        try {
                          if (!user) return;
                          const res = await fetch(`/api/dashboard/settings?userId=${encodeURIComponent(user.id)}`);
                          if (!res.ok) {
                            console.warn('Failed to fetch settings', await res.text());
                            setEmailNotificationsEnabled(false);
                            setEmailPreferences({});
                            return;
                          }
                          const json = await res.json();
                          const prefs = json?.preferences || {};
                          setEmailPreferences(prefs || {});
                          setEmailNotificationsEnabled(Boolean(prefs?.emailNotifications));
                        } catch (e) {
                          console.error('Error loading settings', e);
                          setEmailNotificationsEnabled(false);
                          setEmailPreferences({});
                        }
                      }}>Configure</Button>
                    </div>
                  </div>

                  <Modal open={showEmailSettingsModal} onClose={() => { if (!isSavingEmailSettings) { setShowEmailSettingsModal(false); } }} ariaLabel="Email notification settings">
                    <div className="space-y-4 max-w-md">
                      <h3 className="text-lg font-semibold">Email notifications</h3>
                      <p className="text-sm text-muted-foreground">Choose whether to receive email alerts about important account activity.</p>

                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">Account activity emails</p>
                          <p className="text-sm text-muted-foreground">Sign-in alerts and security notifications</p>
                        </div>
                        <div>
                          <Switch checked={!!emailNotificationsEnabled} onCheckedChange={(v: boolean) => setEmailNotificationsEnabled(v)} />
                        </div>
                      </div>

                      <div className="flex items-center justify-end space-x-2">
                        <Button variant="ghost" onClick={() => setShowEmailSettingsModal(false)} disabled={isSavingEmailSettings}>Cancel</Button>
                        <Button onClick={async () => {
                          if (!user) return;
                          setIsSavingEmailSettings(true);
                          try {
                              const merged = { ...(emailPreferences || {}), emailNotifications: !!emailNotificationsEnabled };
                              const res = await fetch('/api/dashboard/settings', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ userId: user.id, preferences: merged }),
                              });
                            if (!res.ok) {
                              const txt = await res.text();
                              toast.error(`Failed to save settings: ${txt}`);
                              return;
                            }
                            toast.success('Settings saved');
                            setShowEmailSettingsModal(false);
                          } catch (e) {
                            console.error('Save settings error', e);
                            toast.error('Failed to save settings');
                          } finally {
                            setIsSavingEmailSettings(false);
                          }
                        }} disabled={isSavingEmailSettings}>{isSavingEmailSettings ? 'Saving…' : 'Save'}</Button>
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
                        <Button variant="destructive" onClick={() => setShowDeleteModal(true)}>
                          Delete Account
                        </Button>

                        <Modal open={showDeleteModal} onClose={() => { if (!isDeleting) { setShowDeleteModal(false); setDeleteConfirmInput(''); } }} ariaLabel="Confirm account deletion">
                          <div className="space-y-4">
                            <h3 className="text-lg font-semibold">Delete account</h3>
                            <p className="text-sm text-muted-foreground">
                              This will permanently delete your account and all associated data. This action cannot be undone.
                            </p>

                            <div className="text-sm">
                              <p>To confirm, type your email address <strong>{user?.email}</strong> below and click <em>Delete account</em>.</p>
                            </div>

                            <Input
                              placeholder={user?.email || 'Your email'}
                              value={deleteConfirmInput}
                              onChange={(e) => setDeleteConfirmInput(e.target.value)}
                            />

                            <div className="flex items-center justify-end space-x-2">
                              <Button variant="ghost" onClick={() => { if (!isDeleting) { setShowDeleteModal(false); setDeleteConfirmInput(''); } }} disabled={isDeleting}>Cancel</Button>
                              <Button
                                variant="destructive"
                                onClick={async () => {
                                  if (!user) {
                                    toast.error('No authenticated user');
                                    return;
                                  }
                                  if (deleteConfirmInput.trim() !== (user.email || '')) {
                                    toast.error('Confirmation text does not match your email');
                                    return;
                                  }

                                  setIsDeleting(true);
                                  try {
                                    const res = await fetch('/api/dashboard/delete-account', {
                                      method: 'POST',
                                      headers: { 'Content-Type': 'application/json' },
                                      credentials: 'same-origin',
                                      body: JSON.stringify({ userId: user.id }),
                                    });

                                    if (!res.ok) {
                                      const txt = await res.text();
                                      toast.error(`Delete failed: ${txt}`);
                                      setIsDeleting(false);
                                      return;
                                    }

                                    toast.success('Account deleted');
                                    try { await supabase.auth.signOut(); } catch (e) { /* ignore */ }
                                    window.location.href = '/';
                                  } catch (err) {
                                    console.error('Delete account error', err);
                                    toast.error('Failed to delete account');
                                  } finally {
                                    setIsDeleting(false);
                                  }
                                }}
                                disabled={isDeleting || deleteConfirmInput.trim() !== (user?.email || '')}
                              >
                                {isDeleting ? 'Deleting…' : 'Delete account'}
                              </Button>
                            </div>
                          </div>
                        </Modal>
                        
                        {/* 2FA Setup / Verify Modal */}
                        <Modal open={show2FAModal} onClose={() => { if (!isVerifying2FA) { setShow2FAModal(false); setSetupData(null); setVerifyToken(''); } }} ariaLabel="Two-Factor Authentication setup">
                          <div className="space-y-4 max-w-md">
                            <h3 className="text-lg font-semibold">Set up Two-Factor Authentication</h3>
                            <p className="text-sm text-muted-foreground">Scan the QR code below with your authenticator app (or enter the secret manually), then enter a generated code to verify and enable 2FA.</p>

                            {setupData?.qrDataUrl ? (
                              <div className="flex justify-center">
                                {/* eslint-disable-next-line @next/next/no-img-element */}
                                <img src={setupData.qrDataUrl} alt="2FA QR code" className="w-48 h-48 object-contain" />
                              </div>
                            ) : (
                              <div className="p-4 bg-muted rounded">No QR available; use the manual secret</div>
                            )}

                            <div>
                              <Label>Secret (manual)</Label>
                              <div className="flex items-center space-x-2">
                                <Input value={setupData?.secret || ''} readOnly />
                                <Button onClick={() => { if (setupData?.secret) { navigator.clipboard?.writeText(setupData.secret); toast.success('Secret copied'); } }}>Copy</Button>
                              </div>
                            </div>

                            <div>
                              <Label>Code from authenticator</Label>
                              <Input placeholder="123456" value={verifyToken} onChange={(e) => setVerifyToken(e.target.value)} />
                            </div>

                            {twoFAError && <p className="text-sm text-destructive">{twoFAError}</p>}

                            <div className="flex items-center justify-end space-x-2">
                              <Button variant="ghost" onClick={() => { if (!isVerifying2FA) { setShow2FAModal(false); setSetupData(null); setVerifyToken(''); } }} disabled={isVerifying2FA}>Cancel</Button>
                              <Button
                                onClick={async () => {
                                  if (!user) {
                                    setTwoFAError('No authenticated user');
                                    return;
                                  }
                                  if (!setupData?.secret) {
                                    setTwoFAError('Missing secret to verify');
                                    return;
                                  }
                                  if (!verifyToken || !/^[0-9]{6,8}$/.test(verifyToken.trim())) {
                                    setTwoFAError('Please enter a valid code from your authenticator app');
                                    return;
                                  }

                                  setTwoFAError(null);
                                  setIsVerifying2FA(true);
                                  try {
                                    const res = await fetch('/api/dashboard/2fa/verify', {
                                      method: 'POST',
                                      headers: { 'Content-Type': 'application/json' },
                                      body: JSON.stringify({ userId: user.id, secret: setupData.secret, token: verifyToken.trim() }),
                                    });
                                    if (!res.ok) {
                                      const txt = await res.text();
                                      setTwoFAError(`Verification failed: ${txt}`);
                                      return;
                                    }
                                    const json = await res.json();
                                    if (json?.success) {
                                      setTwoFAEnabled(true);
                                      toast.success('Two-Factor Authentication enabled');
                                      setShow2FAModal(false);
                                      setSetupData(null);
                                      setVerifyToken('');
                                      try {
                                        await fetch('/api/dashboard/activities', {
                                          method: 'POST',
                                          headers: { 'Content-Type': 'application/json' },
                                          body: JSON.stringify({ userId: user.id, title: 'Enabled 2FA', description: 'User enabled two-factor authentication' }),
                                        });
                                      } catch (e) {
                                        console.warn('Failed to log 2FA enable activity', e);
                                      }
                                    } else if (json?.error) {
                                      setTwoFAError(json.error || 'Verification failed');
                                    } else {
                                      // handle server warning (preferences missing)
                                      if (json?.warning) {
                                        setTwoFAEnabled(true);
                                        toast.success('Two-Factor Authentication enabled (not persisted)');
                                        setShow2FAModal(false);
                                        setSetupData(null);
                                        setVerifyToken('');
                                        try {
                                          await fetch('/api/dashboard/activities', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/json' },
                                            body: JSON.stringify({ userId: user.id, title: 'Enabled 2FA', description: 'User enabled two-factor authentication (not persisted)' }),
                                          });
                                        } catch (e) {
                                          console.warn('Failed to log 2FA enable activity', e);
                                        }
                                      } else {
                                        setTwoFAError('Verification response unexpected');
                                      }
                                    }
                                  } catch (err) {
                                    console.error('2FA verify error', err);
                                    setTwoFAError('Verification failed');
                                  } finally {
                                    setIsVerifying2FA(false);
                                  }
                                }}
                                disabled={isVerifying2FA}
                              >
                                {isVerifying2FA ? 'Verifying…' : 'Verify & Enable'}
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
    </DashboardLayout>
  );
}
