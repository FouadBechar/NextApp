"use client";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { signupSchema } from "@/lib/utils/validation";
import { zodResolver } from "@hookform/resolvers/zod";
import { motion } from "framer-motion";
import PasswordInput from "@/components/ui/password-input";
import { executeRecaptchaSafe } from "@/lib/utils/recaptcha";
import { extractMessageFromObject } from '@/utils/extract-message';
import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";

type FormData = z.infer<typeof signupSchema>;

export function SignupForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  // visibility toggle is handled by `PasswordInput`

  const form = useForm<FormData>({
    resolver: zodResolver(signupSchema),
    mode: "onChange",
    defaultValues: {
      username: "",
      email: "",
      password: "",
      confirmPassword: "",
    },
  });

  const [usernameAvailable, setUsernameAvailable] = useState<boolean | null>(
    null
  );
  const [checkingUsername, setCheckingUsername] = useState(false);
  const [emailAvailable, setEmailAvailable] = useState<boolean | null>(null);
  const [checkingEmail, setCheckingEmail] = useState(false);
  const [emailValidationMessage, setEmailValidationMessage] = useState<
    string | null
  >(null);
  const [usernameValidationMessage, setUsernameValidationMessage] = useState<
    string | null
  >(null);

  // Debounced username availability check
  const usernameTimerRef = useRef<number | null>(null);
  const emailTimerRef = useRef<number | null>(null);
  function checkUsername(value: string) {
    const trimmed = value.trim();
    if (usernameTimerRef.current) {
      window.clearTimeout(usernameTimerRef.current);
    }
    if (!trimmed || trimmed.length < 3) {
      setUsernameAvailable(null);
      setUsernameValidationMessage(null);
      return;
    }
    // Only allow letters, numbers, and underscores in username
    const validRe = /^[A-Za-z0-9_]+$/;
    if (!validRe.test(trimmed)) {
      const msg = "Username may only contain letters, numbers and underscores";
      setUsernameValidationMessage(msg);
      // set field error in form so FormMessage displays and form validation picks it up
      try {
        form.setError("username", { type: "manual", message: msg });
      } catch (e) {
        /* ignore */
      }
      setUsernameAvailable(null);
      return;
    }
    setUsernameValidationMessage(null);
    try {
      form.clearErrors("username");
    } catch (e) {
      /* ignore */
    }
    setCheckingUsername(true);
    usernameTimerRef.current = window.setTimeout(async () => {
      try {
        const res = await fetch(
          `/api/auth/username-availability?username=${encodeURIComponent(trimmed)}`
        );
        const json = await res.json();
        setUsernameAvailable(!!json.available);
        if (json.available) {
          try {
            form.clearErrors("username");
          } catch (e) {
            /* ignore */
          }
        } else {
          try {
            form.setError("username", {
              type: "manual",
              message: "Username already taken",
            });
          } catch (e) {
            /* ignore */
          }
        }
      } catch (e) {
        setUsernameAvailable(null);
      } finally {
        setCheckingUsername(false);
      }
    }, 500);
  }

  // Debounced email availability check
  function checkEmail(value: string) {
    const emailTrimmed = value.trim();
    if (emailTimerRef.current) window.clearTimeout(emailTimerRef.current);
    if (!emailTrimmed) {
      setEmailAvailable(null);
      setEmailValidationMessage(null);
      return;
    }
    // quick email format check; leave detailed validation to zod
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(emailTrimmed)) {
      setEmailValidationMessage("Please enter a valid email address");
      try {
        form.setError("email", {
          type: "manual",
          message: "Please enter a valid email address",
        });
      } catch (e) {
        /* ignore */
      }
      setEmailAvailable(null);
      return;
    }
    setEmailValidationMessage(null);
    try {
      form.clearErrors("email");
    } catch (e) {
      /* ignore */
    }
    setCheckingEmail(true);
    emailTimerRef.current = window.setTimeout(async () => {
      try {
        const res = await fetch(
          `/api/auth/email-availability?email=${encodeURIComponent(emailTrimmed)}`
        );
        const json = await res.json();
        setEmailAvailable(!!json.available);
        if (json.available) {
          try {
            form.clearErrors("email");
          } catch (e) {
            /* ignore */
          }
        } else {
          try {
            form.setError("email", {
              type: "manual",
              message: "That email is already registered",
            });
          } catch (e) {
            /* ignore */
          }
        }
      } catch (e) {
        setEmailAvailable(null);
      } finally {
        setCheckingEmail(false);
      }
    }, 500);
  }

  // cleanup on unmount
  useEffect(() => {
    return () => {
      if (usernameTimerRef.current)
        window.clearTimeout(usernameTimerRef.current);
      if (emailTimerRef.current) window.clearTimeout(emailTimerRef.current);
    };
  }, []);

  async function onSubmit(data: FormData) {
    setIsLoading(true);
    setError(null);

    try {
      const submittedUsername = data.username?.trim();

      // If reCAPTCHA is configured, attempt to execute it and verify
      const siteKey = process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY;
      if (siteKey) {
        try {
          const res = await executeRecaptchaSafe(siteKey, "signup");
          if (!res.ok) {
            // Block signup: show error and return
            setError(res.error || "reCAPTCHA unavailable");
            setIsLoading(false);
            return;
          } else {
            // verify token server-side
            try {
              const verifyRes = await fetch("/api/recaptcha", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ token: res.token, action: "signup" }),
              });
              const contentType = verifyRes.headers.get("content-type") || "";
              if (!verifyRes.ok) {
                let json: Record<string, unknown> | null = null;
                if (contentType.includes("application/json")) json = await verifyRes.json();
                // Block signup if server rejects verification
                setError(extractMessageFromObject(json) || `reCAPTCHA verify failed (${verifyRes.status})`);
                setIsLoading(false);
                return;
              }
              if (contentType.includes("application/json")) {
                const json = await verifyRes.json();
                if (!json?.success) {
                  setError(extractMessageFromObject(json) || "reCAPTCHA verification failed");
                  setIsLoading(false);
                  return;
                }
              } else {
                setError("reCAPTCHA verify returned non-JSON response");
                setIsLoading(false);
                return;
              }
            } catch (verifyErr) {
              // Block signup if verification throws
              setError((verifyErr as Error).message || String(verifyErr));
              setIsLoading(false);
              return;
            }
          }
        } catch (recErr) {
          setError((recErr as Error).message || String(recErr));
          setIsLoading(false);
          return;
        }
      }

      const response = await fetch("/api/resend", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          type: "verification",
          email: data.email,
          password: data.password,
          username: submittedUsername,
        }),
      });

      if (!response.ok) {
        const result = await response.json().catch(() => null);
        throw new Error(result?.error ?? "Failed to send verification email");
      }

      sessionStorage.setItem("verificationEmail", data.email);
      if (submittedUsername) {
        sessionStorage.setItem("verificationUsername", submittedUsername);
      }

      router.push("/auth/verify");
    } catch (error) {
      setError(
        error instanceof Error
          ? error.message
          : "An error occurred during signup"
      );
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="space-y-6">
      {error && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        </motion.div>
      )}

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input
                    placeholder="you@example.com"
                    {...field}
                    onChange={(e) => {
                      field.onChange(e);
                      checkEmail(e.target.value);
                    }}
                  />
                </FormControl>
                <FormMessage />
                <div className="text-sm mt-1">
                  {checkingEmail ? (
                    <span className="text-muted-foreground">Checking...</span>
                  ) : emailAvailable === null ? null : emailAvailable ? (
                    <span className="text-green-600 dark:text-green-400 font-medium">
                      Email available
                    </span>
                  ) : null}
                </div>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="username"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Username</FormLabel>
                <FormControl>
                  <Input
                    placeholder="yourusername"
                    {...field}
                    onChange={(e) => {
                      field.onChange(e);
                      checkUsername(e.target.value);
                    }}
                  />
                </FormControl>
                <FormMessage />
                <div className="text-sm mt-1">
                  {checkingUsername ? (
                    <span className="text-muted-foreground">Checking...</span>
                  ) : usernameAvailable === null ? null : usernameAvailable ? (
                    <span className="text-green-600 dark:text-green-400 font-medium">
                      Username available
                    </span>
                  ) : null}
                </div>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="password"
            render={({ field }) => {
              const { ref, ...rest } = field as unknown as { ref?: React.LegacyRef<HTMLInputElement> } & Record<string, unknown>;
              return (
                <FormItem>
                  <FormLabel>Password</FormLabel>
                  <FormControl>
                    <PasswordInput
                      inputRef={ref}
                      placeholder="••••••••"
                      {...rest}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              );
            }}
          />

          <FormField
            control={form.control}
            name="confirmPassword"
            render={({ field }) => {
              const { ref, ...rest } = field as unknown as { ref?: React.LegacyRef<HTMLInputElement> } & Record<string, unknown>;
              return (
                <FormItem>
                  <FormLabel>Confirm Password</FormLabel>
                  <FormControl>
                    <PasswordInput
                      inputRef={ref}
                      placeholder="••••••••"
                      {...rest}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              );
            }}
          />

          <Button
            type="submit"
            className="w-full"
            disabled={
              isLoading ||
              !!usernameValidationMessage ||
              !!emailValidationMessage ||
              usernameAvailable === false ||
              checkingUsername ||
              emailAvailable === false ||
              checkingEmail ||
              !form.formState.isValid
            }
          >
            {isLoading ? "Creating account..." : "Create account"}
          </Button>
        </form>
      </Form>

      <div className="text-center text-sm">
        Already have an account?{" "}
        <Link href="/auth/login" className="text-blue-600 hover:underline">
          Sign in
        </Link>
      </div>
    </div>
  );
}
