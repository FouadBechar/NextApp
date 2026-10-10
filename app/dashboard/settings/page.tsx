'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Separator } from '@/components/ui/separator';
import { Switch } from '@/components/ui/switch';
import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import Modal from '@/components/ui/modal';
import { motion } from 'framer-motion';
import { useTheme } from 'next-themes';

type ThemePreference = 'system' | 'light' | 'dark';

function parseThemePreference(value: unknown): ThemePreference {
  return value === 'light' || value === 'dark' || value === 'system'
    ? value
    : 'system';
}

export default function SettingsPage() {
  const router = useRouter();
  const { setTheme: applyTheme } = useTheme();
  const supabaseRef = useRef<ReturnType<typeof createClient> | null>(null);
  const applyThemeRef = useRef(applyTheme);
  const [isLoading, setIsLoading] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [marketingEmails, setMarketingEmails] = useState(false);
  const [animationsEnabled, setAnimationsEnabled] = useState(true);
  const [selectedTheme, setSelectedTheme] = useState<ThemePreference>('system');
  const [isSaving, setIsSaving] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [exportUrl, setExportUrl] = useState<string | null>(null);
  const [emailUrl, setEmailUrl] = useState<string | null>(null);
  const [showExportConfirm, setShowExportConfirm] = useState(false);
  const exportUrlRef = useRef<string | null>(null);
  const [fileSizeNotice, setFileSizeNotice] = useState<string | null>(null);
  const [sendToEmail, setSendToEmail] = useState(false);
  const [isDownloading, setIsDownloading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [serverWarning, setServerWarning] = useState<string | null>(null);
  // keep a copy of the loaded preferences so we can detect if anything changed
  const [loadedPrefs, setLoadedPrefs] = useState<{
    emailNotifications: boolean;
    securityAlerts: boolean;
    marketingEmails: boolean;
    animationsEnabled: boolean;
    theme: ThemePreference;
  } | null>(null);

  useEffect(() => {
    applyThemeRef.current = applyTheme;
  }, [applyTheme]);

  function getSupabaseClient() {
    if (supabaseRef.current) return supabaseRef.current;
    supabaseRef.current = createClient();
    return supabaseRef.current;
  }

  useEffect(() => {
    const controller = new AbortController();

    async function getUser() {
      const supabase = getSupabaseClient();
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session) {
        // Handle no session case if needed
      }

      // load preferences for the user
      try {
        if (session?.user) {
          const res = await fetch(`/api/dashboard/settings?userId=${session.user.id}`, { signal: controller.signal });
          if (res.ok) {
            const json = await res.json();
            const prefs = json?.preferences || {};
            // Server may return a warning when the DB column is missing; surface it in UI
            setServerWarning(json?.warning || null);
            const nextEmail = prefs.emailNotifications ?? true;
            const nextSecurity = true;
            const nextMarketing = prefs.marketingEmails ?? false;
            const nextAnimations = prefs.animationsEnabled ?? true;
            const nextTheme = parseThemePreference(prefs.theme);

            setEmailNotifications(nextEmail);
            setMarketingEmails(nextMarketing);
            setAnimationsEnabled(nextAnimations);
            setSelectedTheme(nextTheme);
            applyThemeRef.current(nextTheme);

            setLoadedPrefs({
              emailNotifications: nextEmail,
              securityAlerts: nextSecurity,
              marketingEmails: nextMarketing,
              animationsEnabled: nextAnimations,
              theme: nextTheme,
            });
          } else {
            console.warn('Failed to load settings', await res.text());
          }
        }
      } catch (err: unknown) {
        if (err instanceof Error && err.name === 'AbortError') {
          // ignore
        } else {
          console.error('Error loading settings', err);
        }
      }

      setIsLoading(false);
    }

    getUser();

    return () => controller.abort();
  }, []);

  useEffect(() => {
    if (typeof document === 'undefined') return;

    const root = document.documentElement;
    root.dataset.animations = animationsEnabled ? 'on' : 'off';

    return () => {
      delete root.dataset.animations;
    };
  }, [animationsEnabled]);

  // cleanup object URL when unmounting or when a new export is created
  useEffect(() => {
    return () => {
      if (exportUrlRef.current) {
        try { URL.revokeObjectURL(exportUrlRef.current); } catch (e) { /* ignore */ }
        exportUrlRef.current = null;
      }
    };
  }, []);

  async function handleExport(sendEmail = false) {
    setShowExportConfirm(false);
    setFileSizeNotice(null);
    setMessage(null);
    setError(null);
    setEmailUrl(null);
    setIsExporting(true);
    try {
      const supabase = getSupabaseClient();
      const { data: { session } } = await supabase.auth.getSession();
      if (!session?.user) {
        setError('Not authenticated');
        return;
      }
      const res = await fetch('/api/dashboard/export', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: session.user.id, sendEmail }),
      });
      if (!res.ok) {
        // try to parse structured error first
        try {
          const j = await res.json();
          setError(j?.error ? String(j.error) : `Failed to export: ${res.status}`);
        } catch (e) {
          const txt = await res.text();
          setError(`Failed to export: ${txt}`);
        }
        return;
      }

      const json = await res.json();
      const emailed = Boolean(json?.emailSent);
      const exportPayload = json?.export ?? {};
      const name = `export-${session.user.id}-${Date.now()}.json`;
      // If the server emailed the export, don't attempt to download a local copy.
      if (emailed) {
        setMessage('Your export was emailed to you.');
        return;
      }
      const blob = new Blob([JSON.stringify(exportPayload, null, 2)], { type: 'application/json' });
      const sizeKB = Math.ceil(blob.size / 1024);
      if (sizeKB > 10 * 1024) {
        // large file (>10MB), surface a notice
        setFileSizeNotice(`This export is ${Math.round(sizeKB / 1024)} MB. It may take some time to download.`);
      }
      const url = URL.createObjectURL(blob);
      // revoke previous url if any
      if (exportUrlRef.current) {
        try { URL.revokeObjectURL(exportUrlRef.current); } catch (e) { /* ignore */ }
      }
      exportUrlRef.current = url;
      setExportUrl(url);
      // programmatically trigger a download for convenience
      try {
        setIsDownloading(true);
        const a = document.createElement('a');
        a.href = url;
        a.download = name;
        a.setAttribute('data-export-name', name);
        document.body.appendChild(a);
        a.click();
        a.remove();
      } finally {
        setIsDownloading(false);
        // revoke the object URL after a short delay to ensure the download starts
        setTimeout(() => {
          if (exportUrlRef.current) {
            try { URL.revokeObjectURL(exportUrlRef.current); } catch (e) { /* ignore */ }
            exportUrlRef.current = null;
            setExportUrl(null);
          }
        }, 10_000);
      }

      if (emailed) {
        setMessage('Your export was emailed to you.');
        if (json?.emailUrl) setEmailUrl(json.emailUrl as string);
      } else {
        setMessage('Export created — the download should have started.');
      }
    } catch (e) {
      console.error('Export error', e);
      setError('Failed to create export');
    } finally {
      setIsExporting(false);
    }
  }

  if (isLoading) {
    // Render a minimal loading state so the layout doesn't appear blank
    return (
      <>
        <div className="py-8">
          <h2 className="text-2xl font-bold tracking-tight">Settings</h2>
          <p className="text-sm text-muted-foreground mt-2">Loading settings…</p>
        </div>
      </>
    );
  }

  const notificationsChanged =
    loadedPrefs !== null &&
    (loadedPrefs.emailNotifications !== emailNotifications ||
      loadedPrefs.securityAlerts !== true ||
      loadedPrefs.marketingEmails !== marketingEmails);

  return (
    <>
      <div className="space-y-6">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Settings</h2>
          <p className="text-muted-foreground">Manage your application settings and preferences.</p>
          {serverWarning && (
            <div className="mt-3 p-3 rounded bg-yellow-50 border border-yellow-200 text-sm text-yellow-800">
              {serverWarning}
            </div>
          )}
        </div>

        <Separator />

        <div className="grid grid-cols-1 gap-6">
          {/* Notification Settings */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between gap-3">
                  <CardTitle>Notifications</CardTitle>
                  {notificationsChanged && (
                    <span className="rounded bg-muted px-2 py-1 text-xs font-medium text-muted-foreground">
                      Unsaved changes
                    </span>
                  )}
                </div>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="email-notifications">
                      Account Emails
                    </Label>
                    <p className="text-sm text-muted-foreground">
                      Receive important updates about your account, replies, and activity.
                    </p>
                  </div>
                  <Switch id="email-notifications" checked={emailNotifications} onCheckedChange={(v) => setEmailNotifications(!!v)} />
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="security-alerts">Security Alerts</Label>
                    <p className="text-sm text-muted-foreground">
                      Required for account protection: password resets, 2FA changes, data exports, and important sign-in activity.
                    </p>
                    <p className="text-xs font-medium text-muted-foreground">Always on</p>
                  </div>
                  <Switch id="security-alerts" checked disabled aria-readonly="true" />
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="marketing-emails">Product Updates</Label>
                    <p className="text-sm text-muted-foreground">
                      Occasional feature announcements, improvements, and promotions.
                    </p>
                  </div>
                  <Switch id="marketing-emails" checked={marketingEmails} onCheckedChange={(v) => setMarketingEmails(!!v)} />
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Appearance Settings */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Appearance</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-3 gap-4">
                  <div className="flex flex-col items-center gap-2">
                    <button
                      type="button"
                      className={`rounded-md p-2 border-2 transition-colors ${selectedTheme === 'system' ? 'border-primary bg-accent/40' : 'border-muted hover:border-border'}`}
                      onClick={() => {
                        setSelectedTheme('system');
                        applyTheme('system');
                      }}
                      aria-pressed={selectedTheme === 'system'}
                      aria-label="Select system theme"
                      title="Select system theme"
                    >
                      <div className="w-full h-24 bg-background rounded-md border border-border"></div>
                    </button>
                    <span className="text-sm font-medium">System</span>
                  </div>

                  <div className="flex flex-col items-center gap-2">
                    <button
                      type="button"
                      className={`rounded-md p-2 border-2 transition-colors ${selectedTheme === 'light' ? 'border-primary bg-accent/40' : 'border-muted hover:border-border'}`}
                      onClick={() => {
                        setSelectedTheme('light');
                        applyTheme('light');
                      }}
                      aria-pressed={selectedTheme === 'light'}
                      aria-label="Select light theme"
                      title="Select light theme"
                    >
                      <div className="w-full h-24 bg-white rounded-md border border-gray-200"></div>
                    </button>
                    <span className="text-sm font-medium">Light</span>
                  </div>

                  <div className="flex flex-col items-center gap-2">
                    <button
                      type="button"
                      className={`rounded-md p-2 border-2 transition-colors ${selectedTheme === 'dark' ? 'border-primary bg-accent/40' : 'border-muted hover:border-border'}`}
                      onClick={() => {
                        setSelectedTheme('dark');
                        applyTheme('dark');
                      }}
                      aria-pressed={selectedTheme === 'dark'}
                      aria-label="Select dark theme"
                      title="Select dark theme"
                    >
                      <div className="w-full h-24 bg-gray-950 rounded-md border border-gray-800"></div>
                    </button>
                    <span className="text-sm font-medium">Dark</span>
                  </div>
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="animations">Interface Animations</Label>
                    <p className="text-sm text-muted-foreground">
                      Enable animations throughout the interface
                    </p>
                  </div>
                  <Switch id="animations" checked={animationsEnabled} onCheckedChange={(v) => setAnimationsEnabled(!!v)} />
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Privacy Settings */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Privacy & Security</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="two-factor">
                      Two-Factor Authentication
                    </Label>
                    <p className="text-sm text-muted-foreground">
                      Add an extra layer of security to your account
                    </p>
                  </div>
                  <Button variant="outline" size="sm" onClick={() => router.push('/dashboard/profile?open2fa=true')}>
                    Setup
                  </Button>
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="activity-log">Activity Log</Label>
                    <p className="text-sm text-muted-foreground">
                      View a history of your account activity
                    </p>
                  </div>
                  <Button variant="outline" size="sm" onClick={() => router.push('/dashboard/profile?openActivity=true')}>
                    View Log
                  </Button>
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="data-export">Export Your Data</Label>
                    <p className="text-sm text-muted-foreground">
                      Download a copy of your personal data
                    </p>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setShowExportConfirm(true)}
                      disabled={isExporting}
                      aria-describedby="export-info"
                    >
                      {isExporting ? 'Exporting…' : 'Export'}
                    </Button>
                    {exportUrl && (
                      <a className="text-sm text-primary underline" href={exportUrl} target="_blank" rel="noopener noreferrer">Download</a>
                    )}
                    {emailUrl && (
                      <a className="text-sm text-primary underline" href={emailUrl} target="_blank" rel="noopener noreferrer">Download from email link</a>
                    )}
                  </div>
                </div>
                <div className="pt-2">
                  <p id="export-info" className="text-xs text-muted-foreground">{fileSizeNotice ?? 'Includes profile and up to 1000 recent activities.'}</p>
                </div>
                <Modal open={showExportConfirm} onClose={() => setShowExportConfirm(false)} ariaLabel="Confirm data export">
                  <h2 className="text-lg font-semibold">Confirm export</h2>
                  <p className="text-sm text-muted-foreground mt-2">This will generate a JSON file containing your profile and up to 1000 recent activities. The file may contain personal data. You can download it directly from your browser.</p>
                  {fileSizeNotice && <p className="text-sm text-muted-foreground mt-2">{fileSizeNotice}</p>}
                  <div className="mt-4">
                    <label className="inline-flex items-center space-x-2">
                      <input type="checkbox" checked={sendToEmail} onChange={(e) => setSendToEmail(e.target.checked)} />
                      <span className="text-sm">Email this export to my account email</span>
                    </label>
                    <div className="mt-4 flex justify-end space-x-2">
                      <Button variant="outline" size="sm" onClick={() => setShowExportConfirm(false)}>Cancel</Button>
                      <Button size="sm" onClick={() => handleExport(sendToEmail)} disabled={isExporting || isDownloading} aria-disabled={isExporting || isDownloading}>{isExporting || isDownloading ? 'Exporting…' : 'Confirm export'}</Button>
                    </div>
                  </div>
                </Modal>
              </CardContent>
            </Card>
          </motion.div>

          {/* Save Settings */}
          <div className="flex justify-end">
            <div className="flex flex-col items-end">
              <div className="mb-2">
                {message && <p role="status" className="text-sm text-green-600">{message}</p>}
                {error && <p role="alert" className="text-sm text-destructive">{error}</p>}
              </div>
              <Button
                onClick={async () => {
                  setMessage(null);
                  setError(null);
                  setIsSaving(true);
                  try {
                    const supabase = getSupabaseClient();
                    const {
                      data: { session },
                    } = await supabase.auth.getSession();
                    if (!session?.user) {
                      setError('Not authenticated');
                      return;
                    }

                      const prefs = {
                        emailNotifications,
                        securityAlerts: true,
                        marketingEmails,
                        animationsEnabled,
                        theme: selectedTheme,
                      };

                    const res = await fetch('/api/dashboard/settings', {
                      method: 'POST',
                      headers: {
                        'Content-Type': 'application/json',
                      },
                      body: JSON.stringify({ userId: session.user.id, preferences: prefs }),
                    });

                    if (res.ok) {
                      const json = await res.json();
                      setLoadedPrefs(prefs);
                      setMessage('Settings saved');
                      // show non-blocking server warning when preferences couldn't be persisted
                      if (json?.warning) {
                        setServerWarning(json.warning as string);
                      } else {
                        setServerWarning(null);
                      }
                    } else {
                      // try to parse JSON error body, fall back to text
                      try {
                        const j = await res.json();
                        setError(j?.error ? String(j.error) : JSON.stringify(j));
                      } catch (e) {
                        const txt = await res.text();
                        setError(`Save failed: ${txt}`);
                      }
                    }
                  } catch (err) {
                    console.error('Save settings error', err);
                    setError('Unexpected error while saving settings');
                  } finally {
                    setIsSaving(false);
                  }
                }}
                disabled={isSaving || (
                  // disable when nothing changed compared to loadedPrefs
                  loadedPrefs !== null &&
                  loadedPrefs.emailNotifications === emailNotifications &&
                  loadedPrefs.securityAlerts === true &&
                  loadedPrefs.marketingEmails === marketingEmails &&
                  loadedPrefs.animationsEnabled === animationsEnabled &&
                  loadedPrefs.theme === selectedTheme
                )}
              >
                {isSaving ? 'Saving…' : 'Save Settings'}
              </Button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
