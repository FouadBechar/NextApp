"use client";

import React, { useEffect, useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import rehypeSanitize from "rehype-sanitize";
import remarkGfm from "remark-gfm";
import SafeImage from "./ui/SafeImage";
const icon = "/assets/chat-icon.png";
const icon1 = "/assets/icon1.svg";
const icon2 = "/assets/icon2.svg";
const icon3 = "/assets/icon3.webp";
const CHAT_STORAGE_KEY = "nextapp:chat-widget:history";
const CHAT_API_URL = process.env.NEXT_PUBLIC_CHAT_API_URL || "/api/chat";
const DEFAULT_MODEL =
  process.env.NEXT_PUBLIC_CHAT_DEFAULT_MODEL || "openai/gpt-4o-mini";
const ENABLE_WARMUP = process.env.NEXT_PUBLIC_CHAT_WARMUP === "true";
const TYPEWRITER_DELAY_MS = 18;

type ChatMessage = {
  role: string;
  text?: string;
  content?: string;
};

type ChatResponse = { reply?: string; error?: string };

function sanitizeLinksReact(text: string): React.ReactNode[] {
  const urlRegex = /(https?:\/\/[^\s]+)/g;
  const parts: React.ReactNode[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  while ((match = urlRegex.exec(text)) !== null) {
    const url = match[0];
    if (match.index > lastIndex) {
      parts.push(text.slice(lastIndex, match.index));
    }
    parts.push(
      <a key={match.index} href={url} target="_blank" rel="noopener noreferrer">
        {url}
      </a>,
    );
    lastIndex = match.index + url.length;
  }
  if (lastIndex < text.length) parts.push(text.slice(lastIndex));
  return parts;
}

function renderMessageContent(message: ChatMessage) {
  const text = message.text ?? message.content ?? "";

  if (message.role === "bot") {
    return (
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeSanitize]}
        components={{
          a: ({ children, ...props }) => (
            <a {...props} target="_blank" rel="noopener noreferrer">
              {children}
            </a>
          ),
        }}
      >
        {text}
      </ReactMarkdown>
    );
  }

  return typeof text === "string" ? sanitizeLinksReact(text) : text;
}

export default function ChatWidget() {
  const [messages, setMessages] = useState<ChatMessage[]>([]); // {role, text}
  const [open, setOpen] = useState(false);
  const [input, setInput] = useState("");
  const [sending, setSending] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const messagesRef = useRef<HTMLDivElement | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);
  const typewriterIntervalRef = useRef<number | null>(null);
  const typewriterResolveRef = useRef<(() => void) | null>(null);

  // Removed injected CSS; styles are now managed in app/globals.css

  useEffect(() => {
    // load history
    try {
      const hist: any[] = JSON.parse(
        localStorage.getItem(CHAT_STORAGE_KEY) || "[]",
      );
      // normalize older entries that used `content` property -> map to `text` for the UI
      const normalized: ChatMessage[] = (hist || []).map((m: any) => ({
        role: String(m?.role ?? "user"),
        text:
          typeof m?.text === "string"
            ? m.text
            : typeof m?.content === "string"
              ? m.content
              : "",
      }));
      setMessages(normalized);
    } catch (err) {
      console.debug("ChatWidget load history error", err);
    }
    if (!ENABLE_WARMUP) {
      return;
    }

    // warm up connection (fire-and-forget)
    (async function warmUp() {
      try {
        await fetch(CHAT_API_URL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: DEFAULT_MODEL,
            messages: [{ role: "system", content: "warmup" }],
          }),
        });
      } catch (err) {
        console.debug("ChatWidget warmUp error", err);
      }
    })();
  }, []);

  useEffect(() => {
    // persist
    try {
      localStorage.setItem(CHAT_STORAGE_KEY, JSON.stringify(messages));
    } catch (err) {
      console.debug("ChatWidget persist error", err);
    }
  }, [messages]);

  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort();
      stopTypewriter(true);
    };
  }, []);

  useEffect(() => {
    // scroll to bottom whenever messages change
    try {
      if (messagesRef.current) {
        const el = messagesRef.current;
        el.scrollTop = el.scrollHeight;
      }
    } catch (err) {
      console.debug("ChatWidget scroll error", err);
    }
  }, [messages]);

  function stopTypewriter(resolvePending = false) {
    if (typewriterIntervalRef.current !== null) {
      window.clearInterval(typewriterIntervalRef.current);
      typewriterIntervalRef.current = null;
    }

    if (resolvePending && typewriterResolveRef.current) {
      typewriterResolveRef.current();
      typewriterResolveRef.current = null;
    }
  }

  function clearHistory() {
    stopTypewriter(true);
    try {
      localStorage.removeItem(CHAT_STORAGE_KEY);
    } catch (err) {
      console.debug("ChatWidget clearHistory error", err);
    }
    setMessages([]);
  }

  function typeBotReply(reply: string) {
    stopTypewriter(true);

    setMessages((m) => [...m, { role: "bot", text: "" }]);

    return new Promise<void>((resolve) => {
      typewriterResolveRef.current = resolve;
      let index = 0;

      typewriterIntervalRef.current = window.setInterval(() => {
        index += 1;

        setMessages((m) => {
          const next = [...m];
          const lastIndex = next.length - 1;
          const lastMessage = next[lastIndex];

          if (!lastMessage || lastMessage.role !== "bot") {
            return m;
          }

          next[lastIndex] = {
            ...lastMessage,
            text: reply.slice(0, index),
          };
          return next;
        });

        if (index >= reply.length) {
          stopTypewriter();
          typewriterResolveRef.current = null;
          resolve();
        }
      }, TYPEWRITER_DELAY_MS);
    });
  }

  async function sendMessage() {
    const text = input.trim();
    if (!text) {
      // show a bot message for empty
      setMessages((m) => [
        ...m,
        { role: "bot", text: "⚠️ Message is empty. Please say something." },
      ]);
      return;
    }
    if (text.length > 300) {
      setMessages((m) => [
        ...m,
        { role: "bot", text: "Your message is too long. Please shorten it." },
      ]);
      return;
    }

    setMessages((m) => [...m, { role: "user", text }]);
    setInput("");
    setSending(true);
    setIsTyping(true);

    try {
      abortControllerRef.current?.abort();
      const controller = new AbortController();
      abortControllerRef.current = controller;

      // Build payload that matches backend expectations: array of { role, content }
      const backendMessages = messages.map((m: ChatMessage) => ({
        role: m.role === "bot" ? "assistant" : m.role,
        content: m.text ?? m.content ?? "",
      }));
      backendMessages.push({ role: "user", content: text });

      const enableChatDebug =
        process.env.NEXT_PUBLIC_CHAT_DEBUG === "true" ||
        process.env.NODE_ENV !== "production";
      if (enableChatDebug) {
        console.debug("ChatWidget: sending request", {
          apiUrl: CHAT_API_URL,
          model: DEFAULT_MODEL,
        });
      }
      const res = await fetch(CHAT_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        signal: controller.signal,
        body: JSON.stringify({
          model: DEFAULT_MODEL,
          messages: backendMessages,
        }),
      });

      // If server returned non-2xx, read the body for details to surface in the UI
      if (!res.ok) {
        let errText = res.statusText;
        try {
          const data: ChatResponse = await res.json();
          errText = data.error || errText;
        } catch (err) {
          console.debug("ChatWidget read error body", err);
        }
        throw new Error(errText || "The chat service is unavailable.");
      }

      const data: ChatResponse = await res.json();
      if (!data.reply) throw new Error("No valid response body from the bot.");
      setIsTyping(false);
      await typeBotReply(String(data.reply));
    } catch (err) {
      setIsTyping(false);
      if (err instanceof DOMException && err.name === "AbortError") {
        return;
      }
      const messageText = err instanceof Error ? err.message : String(err);
      setMessages((m) => [
        ...m,
        { role: "bot", text: `🤖 Error while connecting: ${messageText}` },
      ]);
    } finally {
      abortControllerRef.current = null;
      setSending(false);
    }
  }

  return (
    <>
      <button
        id="chat-toggle"
        type="button"
        aria-label="Open Chat"
        onClick={() => setOpen(true)}
        className={open ? "hidden" : ""}
      >
        <SafeImage src={icon} alt="chat-Logo" width={50} height={31} />
      </button>

      <div id="chat-box" className={open ? "open" : ""}>
        <div id="chat-header">
          <span>
            <SafeImage className="img707" src={icon3} alt="icon3" />
          </span>
          <button id="clear-btn" title="Clear Chat" onClick={clearHistory}>
            <SafeImage className="img708" src={icon1} alt="icon1" />
          </button>
          <button id="close-btn" title="Close" onClick={() => setOpen(false)}>
            <SafeImage className="img709" src={icon2} alt="icon2" />
          </button>
        </div>

        <div id="chat-messages" ref={messagesRef}>
          {messages.map((m, idx) => (
            <div className={`bubble ${m.role}`} key={idx}>
              <div className="bubble-content">{renderMessageContent(m)}</div>
            </div>
          ))}
          {isTyping && (
            <div
              className={`bubble bot`}
              key="typing"
              role="status"
              aria-live="polite"
              aria-atomic="true"
            >
              <div className="bubble-content">
                <span className="chatwidget-typing-dots" aria-hidden="true">
                  <span></span>
                  <span></span>
                  <span></span>
                </span>
                <span className="chatwidget-sr-only">Bot is typing…</span>
              </div>
            </div>
          )}
        </div>

        <div id="chat-input">
          <input
            type="text"
            id="user-input"
            placeholder="Type your message..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                if (!sending) sendMessage();
              }
            }}
          />
          <button
            type="button"
            id="send-btn"
            title="send-btn"
            onClick={() => !sending && sendMessage()}
            disabled={sending}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="svg-icon-001"
              viewBox="0 0 1024 1024"
              version="1.1"
            >
              <path d="M41.353846 876.307692l86.646154-320.984615h366.276923c9.846154 0 19.692308-9.846154 19.692308-19.692308v-39.384615c0-9.846154-9.846154-19.692308-19.692308-19.692308H128l-84.676923-315.076923C41.353846 157.538462 39.384615 151.630769 39.384615 145.723077c0-13.784615 13.784615-27.569231 29.538462-25.6 3.938462 0 5.907692 1.969231 9.846154 1.969231l886.153846 364.307692c11.815385 3.938462 19.692308 15.753846 19.692308 27.569231s-7.876923 21.661538-17.723077 25.6L78.769231 913.723077c-3.938462 1.969231-7.876923 1.969231-11.815385 1.969231-15.753846-1.969231-27.569231-13.784615-27.569231-29.538462 0-3.938462 0-5.907692 1.969231-9.846154z" />
            </svg>
          </button>
        </div>
      </div>
    </>
  );
}
