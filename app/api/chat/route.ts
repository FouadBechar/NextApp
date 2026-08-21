import { NextResponse } from "next/server";

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
const DEFAULT_MODEL =
  process.env.NEXT_PUBLIC_CHAT_DEFAULT_MODEL || "openai/gpt-4o-mini";
const DEFAULT_MAX_TOKENS = 1024;
const MAX_MESSAGES = 20;
const MAX_MESSAGE_CHARS = 300;
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 10;
const SYSTEM_PROMPT =
  "You are NextApp AI, a concise and helpful assistant for website visitors. Answer clearly, stay friendly, and avoid asking for sensitive personal information.";

type RateLimitEntry = {
  count: number;
  resetAt: number;
};

const rateLimitStore = new Map<string, RateLimitEntry>();

type ChatMessage = {
  role?: unknown;
  content?: unknown;
};

function getClientIp(request: Request) {
  const forwardedFor = request.headers.get("x-forwarded-for");

  if (forwardedFor) {
    return forwardedFor.split(",")[0]?.trim() || "unknown";
  }

  return request.headers.get("x-real-ip") || "unknown";
}

function checkRateLimit(key: string) {
  const now = Date.now();
  const current = rateLimitStore.get(key);

  if (!current || current.resetAt <= now) {
    rateLimitStore.set(key, {
      count: 1,
      resetAt: now + RATE_LIMIT_WINDOW_MS,
    });
    return { allowed: true, retryAfter: 0 };
  }

  if (current.count >= RATE_LIMIT_MAX_REQUESTS) {
    return {
      allowed: false,
      retryAfter: Math.ceil((current.resetAt - now) / 1000),
    };
  }

  current.count += 1;
  return { allowed: true, retryAfter: 0 };
}

function normalizeMessages(messages: unknown) {
  if (!Array.isArray(messages)) {
    return [];
  }

  return messages
    .map((message) => message as ChatMessage)
    .map((message) => ({
      role:
        message.role === "assistant" ||
        message.role === "system" ||
        message.role === "user"
          ? message.role
          : "user",
      content: typeof message.content === "string" ? message.content : "",
    }))
    .map((message) => ({
      ...message,
      content: message.content.trim().slice(0, MAX_MESSAGE_CHARS),
    }))
    .filter((message) => message.content.length > 0)
    .slice(-MAX_MESSAGES);
}

export async function POST(request: Request) {
  const apiKey = process.env.OPENROUTER_API_KEY;

  if (!apiKey) {
    console.error("Chat API misconfigured: OPENROUTER_API_KEY is missing.");
    return NextResponse.json(
      { error: "Chat is not configured yet." },
      { status: 500 },
    );
  }

  const rateLimit = checkRateLimit(getClientIp(request));

  if (!rateLimit.allowed) {
    return NextResponse.json(
      { error: "Too many chat requests. Please try again shortly." },
      {
        status: 429,
        headers: {
          "Retry-After": String(rateLimit.retryAfter),
        },
      },
    );
  }

  let body: unknown;

  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON body." }, { status: 400 });
  }

  const payload = body as { messages?: unknown; model?: unknown };
  const messages = normalizeMessages(payload.messages);

  if (messages.length === 0) {
    return NextResponse.json(
      { error: "At least one message is required." },
      { status: 400 },
    );
  }

  try {
    const response = await fetch(OPENROUTER_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": request.headers.get("origin") || "http://localhost:3000",
        "X-Title": "NextApp",
      },
      body: JSON.stringify({
        model: typeof payload.model === "string" ? payload.model : DEFAULT_MODEL,
        messages: [{ role: "system", content: SYSTEM_PROMPT }, ...messages],
        max_tokens: DEFAULT_MAX_TOKENS,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("OpenRouter request failed", {
        status: response.status,
        error,
      });

      return NextResponse.json(
        { error: "The chat service is temporarily unavailable." },
        { status: response.status },
      );
    }

    const data = await response.json();
    const reply = data?.choices?.[0]?.message?.content;

    if (typeof reply !== "string" || reply.length === 0) {
      return NextResponse.json(
        { error: "OpenRouter returned an empty response." },
        { status: 502 },
      );
    }

    return NextResponse.json({ reply });
  } catch (error) {
    console.error("Chat API request failed", error);

    return NextResponse.json(
      { error: "The chat service is temporarily unavailable." },
      { status: 500 },
    );
  }
}
