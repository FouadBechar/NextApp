'use client';

import { DashboardLayout } from '@/components/dashboard/dashboard-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Separator } from '@/components/ui/separator';
import { Switch } from '@/components/ui/switch';
import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { motion } from 'framer-motion';

export default function SettingsPage() {
  const supabase = createClient();
  const [isLoading, setIsLoading] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [securityAlerts, setSecurityAlerts] = useState(true);
  const [marketingEmails, setMarketingEmails] = useState(false);
  const [animationsEnabled, setAnimationsEnabled] = useState(true);
  const [theme, setTheme] = useState<'system' | 'light' | 'dark'>('system');
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [serverWarning, setServerWarning] = useState<string | null>(null);
  // keep a copy of the loaded preferences so we can detect if anything changed
  const [loadedPrefs, setLoadedPrefs] = useState<{
    emailNotifications: boolean;
    securityAlerts: boolean;
    marketingEmails: boolean;
    animationsEnabled: boolean;
    theme: 'system' | 'light' | 'dark';
  } | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    async function getUser() {
      const supabase = createClient();
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
            const nextSecurity = prefs.securityAlerts ?? true;
            const nextMarketing = prefs.marketingEmails ?? false;
            const nextAnimations = prefs.animationsEnabled ?? true;
            const nextTheme = (prefs.theme as 'system' | 'light' | 'dark') || 'system';

            setEmailNotifications(nextEmail);
            setSecurityAlerts(nextSecurity);
            setMarketingEmails(nextMarketing);
            setAnimationsEnabled(nextAnimations);
            setTheme(nextTheme);

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
      } catch (err: any) {
        if (err.name === 'AbortError') {
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

  if (isLoading) {
    // Render a minimal loading state so the layout doesn't appear blank
    return (
      <DashboardLayout>
        <div className="py-8">
          <h2 className="text-2xl font-bold tracking-tight">Settings</h2>
          <p className="text-sm text-muted-foreground mt-2">Loading settings…</p>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
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
                <CardTitle>Notifications</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="email-notifications">
                      Email Notifications
                    </Label>
                    <p className="text-sm text-muted-foreground">
                      Receive email notifications about account activity
                    </p>
                  </div>
                  <Switch id="email-notifications" checked={emailNotifications} onCheckedChange={(v) => setEmailNotifications(!!v)} />
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="security-alerts">Security Alerts</Label>
                    <p className="text-sm text-muted-foreground">
                      Get notified about important security events
                    </p>
                  </div>
                  <Switch id="security-alerts" checked={securityAlerts} onCheckedChange={(v) => setSecurityAlerts(!!v)} />
                </div>

                <Separator />

                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label htmlFor="marketing-emails">Marketing Emails</Label>
                    <p className="text-sm text-muted-foreground">
                      Receive updates about new features and promotions
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
                    <div className="border-2 border-primary rounded-md p-2 cursor-pointer">
                      <div className="w-full h-24 bg-background rounded-md border border-border"></div>
                    </div>
                    <span className="text-sm font-medium">System</span>
                  </div>

                  <div className="flex flex-col items-center gap-2">
                    <div className="border-2 border-muted rounded-md p-2 cursor-pointer">
                      <div className="w-full h-24 bg-white rounded-md border border-gray-200"></div>
                    </div>
                    <span className="text-sm font-medium">Light</span>
                  </div>

                  <div className="flex flex-col items-center gap-2">
                    <div className="border-2 border-muted rounded-md p-2 cursor-pointer">
                      <div className="w-full h-24 bg-gray-950 rounded-md border border-gray-800"></div>
                    </div>
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
                  <Button variant="outline" size="sm">
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
                  <Button variant="outline" size="sm">
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
                  <Button variant="outline" size="sm">
                    Export
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Save Settings */}
          <div className="flex justify-end">
            <div className="flex flex-col items-end">
              <div className="mb-2">
                {message && <p className="text-sm text-green-600">{message}</p>}
                {error && <p className="text-sm text-destructive">{error}</p>}
              </div>
              <Button
                onClick={async () => {
                  setMessage(null);
                  setError(null);
                  setIsSaving(true);
                  try {
                    const {
                      data: { session },
                    } = await supabase.auth.getSession();
                    if (!session?.user) {
                      setError('Not authenticated');
                      return;
                    }

                    const prefs = {
                      emailNotifications,
                      securityAlerts,
                      marketingEmails,
                      animationsEnabled,
                      theme,
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
                  loadedPrefs.securityAlerts === securityAlerts &&
                  loadedPrefs.marketingEmails === marketingEmails &&
                  loadedPrefs.animationsEnabled === animationsEnabled &&
                  loadedPrefs.theme === theme
                )}
              >
                {isSaving ? 'Saving…' : 'Save Settings'}
              </Button>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
