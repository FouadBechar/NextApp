"use client";

import React, { useEffect, useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import rehypeSanitize from "rehype-sanitize";
import remarkGfm from "remark-gfm";
import SafeImage from "./ui/SafeImage";
import styles from "./chatwidget.module.css";

const CHAT_STORAGE_KEY = "nextapp:chat-widget:history";
const MAX_STORED_MESSAGES = 40;
const MAX_REQUEST_MESSAGES = 20;
const REPLY_ANIMATION_MIN_MS = 180;
const REPLY_ANIMATION_MAX_MS = 800;

type ChatRole = "user" | "bot";

type ChatMessage = {
  role: ChatRole;
  text: string;
};

type ChatResponse = { reply?: string };

function parseStoredHistory(value: string | null): ChatMessage[] {
  if (!value) return [];

  const parsed: unknown = JSON.parse(value);
  if (!Array.isArray(parsed)) return [];

  return parsed
    .flatMap((message): ChatMessage[] => {
      if (!message || typeof message !== "object") return [];
      const candidate = message as {
        role?: unknown;
        text?: unknown;
        content?: unknown;
      };
      if (candidate.role !== "user" && candidate.role !== "bot") return [];

      const text =
        typeof candidate.text === "string"
          ? candidate.text
          : typeof candidate.content === "string"
            ? candidate.content
            : "";

      return text ? [{ role: candidate.role, text }] : [];
    })
    .slice(-MAX_STORED_MESSAGES);
}

function sanitizeLinksReact(text: string): React.ReactNode[] {
  const urlRegex = /(https?:\/\/[^\s]+)/g;
  const parts: React.ReactNode[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = urlRegex.exec(text)) !== null) {
    const url = match[0];
    if (match.index > lastIndex) parts.push(text.slice(lastIndex, match.index));
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
        {message.text}
      </ReactMarkdown>
    );
  }

  return sanitizeLinksReact(message.text);
}

export default function ChatWidget() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [open, setOpen] = useState(false);
  const [input, setInput] = useState("");
  const [sending, setSending] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const [historyLoaded, setHistoryLoaded] = useState(false);
  const messagesRef = useRef<HTMLDivElement | null>(null);
  const inputRef = useRef<HTMLInputElement | null>(null);
  const toggleRef = useRef<HTMLButtonElement | null>(null);
  const restoreFocusOnCloseRef = useRef(false);
  const abortControllerRef = useRef<AbortController | null>(null);
  const replyAnimationFrameRef = useRef<number | null>(null);
  const replyAnimationResolveRef = useRef<(() => void) | null>(null);
  const requestVersionRef = useRef(0);

  const appendMessage = (message: ChatMessage) => {
    setMessages((current) => [...current, message].slice(-MAX_STORED_MESSAGES));
  };

  useEffect(() => {
    try {
      setMessages(parseStoredHistory(localStorage.getItem(CHAT_STORAGE_KEY)));
    } catch (error) {
      console.debug("ChatWidget could not load history", error);
    } finally {
      setHistoryLoaded(true);
    }
  }, []);

  useEffect(() => {
    if (!historyLoaded) return;

    try {
      localStorage.setItem(CHAT_STORAGE_KEY, JSON.stringify(messages));
    } catch (error) {
      console.debug("ChatWidget could not save history", error);
    }
  }, [historyLoaded, messages]);

  useEffect(() => {
    if (open) {
      inputRef.current?.focus();
    } else if (restoreFocusOnCloseRef.current) {
      toggleRef.current?.focus();
      restoreFocusOnCloseRef.current = false;
    }
  }, [open]);

  useEffect(() => {
    if (!open) return;

    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") closeChat();
    };
    window.addEventListener("keydown", closeOnEscape);
    return () => window.removeEventListener("keydown", closeOnEscape);
  }, [open]);

  useEffect(() => {
    if (messagesRef.current) {
      messagesRef.current.scrollTop = messagesRef.current.scrollHeight;
    }
  }, [messages, isTyping]);

  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort();
      stopReplyAnimation(true);
    };
  }, []);

  function stopReplyAnimation(resolvePending = false) {
    if (replyAnimationFrameRef.current !== null) {
      window.cancelAnimationFrame(replyAnimationFrameRef.current);
      replyAnimationFrameRef.current = null;
    }
    if (resolvePending && replyAnimationResolveRef.current) {
      replyAnimationResolveRef.current();
      replyAnimationResolveRef.current = null;
    }
  }

  function cancelActiveRequest() {
    requestVersionRef.current += 1;
    abortControllerRef.current?.abort();
    abortControllerRef.current = null;
    stopReplyAnimation(true);
    setIsTyping(false);
    setSending(false);
  }

  function clearHistory() {
    cancelActiveRequest();
    try {
      localStorage.removeItem(CHAT_STORAGE_KEY);
    } catch (error) {
      console.debug("ChatWidget could not clear history", error);
    }
    setMessages([]);
  }

  function closeChat() {
    restoreFocusOnCloseRef.current = true;
    setOpen(false);
  }

  function typeBotReply(reply: string) {
    stopReplyAnimation(true);
    appendMessage({ role: "bot", text: "" });

    return new Promise<void>((resolve) => {
      replyAnimationResolveRef.current = resolve;
      const duration = Math.min(
        REPLY_ANIMATION_MAX_MS,
        Math.max(REPLY_ANIMATION_MIN_MS, reply.length * 2),
      );
      const startedAt = performance.now();

      const animate = (now: number) => {
        const progress = Math.min(1, (now - startedAt) / duration);
        const displayedLength = Math.ceil(reply.length * progress);
        setMessages((current) => {
          const lastIndex = current.length - 1;
          const lastMessage = current[lastIndex];
          if (!lastMessage || lastMessage.role !== "bot") return current;
          const next = [...current];
          next[lastIndex] = { ...lastMessage, text: reply.slice(0, displayedLength) };
          return next;
        });

        if (progress === 1) {
          replyAnimationFrameRef.current = null;
          replyAnimationResolveRef.current = null;
          resolve();
          return;
        }
        replyAnimationFrameRef.current = window.requestAnimationFrame(animate);
      };

      replyAnimationFrameRef.current = window.requestAnimationFrame(animate);
    });
  }

  async function sendMessage() {
    const text = input.trim();
    if (!text) {
      appendMessage({ role: "bot", text: "⚠️ Message is empty. Please say something." });
      return;
    }
    if (text.length > 300) {
      appendMessage({ role: "bot", text: "Your message is too long. Please shorten it." });
      return;
    }

    const requestVersion = ++requestVersionRef.current;
    const requestMessages = [...messages, { role: "user" as const, text }]
      .slice(-MAX_REQUEST_MESSAGES)
      .map((message) => ({
        role: message.role === "bot" ? "assistant" : "user",
        content: message.text,
      }));

    appendMessage({ role: "user", text });
    setInput("");
    setSending(true);
    setIsTyping(true);

    try {
      abortControllerRef.current?.abort();
      const controller = new AbortController();
      abortControllerRef.current = controller;

      const response = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json" },
        signal: controller.signal,
        body: JSON.stringify({ messages: requestMessages }),
      });

      if (!response.ok) {
        throw new Error("The chat service is temporarily unavailable. Please try again.");
      }

      const data: ChatResponse = await response.json();
      if (typeof data.reply !== "string" || !data.reply) {
        throw new Error("The chat service returned an invalid response. Please try again.");
      }
      if (requestVersion !== requestVersionRef.current) return;

      setIsTyping(false);
      await typeBotReply(data.reply);
    } catch (error) {
      if (requestVersion !== requestVersionRef.current) return;
      setIsTyping(false);
      if (error instanceof DOMException && error.name === "AbortError") return;
      appendMessage({
        role: "bot",
        text: "🤖 I’m unable to respond right now. Please try again shortly.",
      });
    } finally {
      if (requestVersion === requestVersionRef.current) {
        abortControllerRef.current = null;
        setSending(false);
      }
    }
  }

  return (
    <>
      <button
        ref={toggleRef}
        type="button"
        aria-label="Open chat"
        aria-controls="chat-box"
        aria-expanded={open}
        onClick={() => setOpen(true)}
        className={`${styles.toggle} ${open ? styles.hidden : ""}`}
      >
        <SafeImage src="/assets/chat-icon.png" alt="" width={50} height={31} />
      </button>

      <section
        id="chat-box"
        className={`${styles.chatBox} ${open ? styles.open : ""}`}
        role="dialog"
        aria-modal="false"
        aria-labelledby="chat-title"
      >
        <header className={styles.header}>
          <h2 id="chat-title" className={styles.srOnly}>NextApp assistant</h2>
          <span className={styles.brandIcon}>
            <SafeImage src="/assets/icon3.webp" alt="" />
          </span>
          <button type="button" className={styles.clearButton} aria-label="Clear chat history" onClick={clearHistory}>
            <SafeImage src="/assets/icon1.svg" alt="" />
          </button>
          <button type="button" className={styles.closeButton} aria-label="Close chat" onClick={closeChat}>
            <SafeImage src="/assets/icon2.svg" alt="" />
          </button>
        </header>

        <div ref={messagesRef} className={styles.messages} role="log" aria-live="polite" aria-relevant="additions text" aria-busy={sending}>
          {messages.map((message, index) => (
            <div className={`${styles.bubble} ${message.role === "user" ? styles.user : styles.bot}`} key={`${message.role}-${index}`}>
              <div className={styles.bubbleContent}>{renderMessageContent(message)}</div>
            </div>
          ))}
          {isTyping && (
            <div className={`${styles.bubble} ${styles.bot}`} role="status" aria-live="polite" aria-atomic="true">
              <div className={styles.bubbleContent}>
                <span className={styles.typingDots} aria-hidden="true"><span /><span /><span /></span>
                <span className={styles.srOnly}>Assistant is typing…</span>
              </div>
            </div>
          )}
        </div>

        <form
          className={styles.inputArea}
          onSubmit={(event) => {
            event.preventDefault();
            if (!sending) void sendMessage();
          }}
        >
          <input
            ref={inputRef}
            type="text"
            aria-label="Message to NextApp assistant"
            placeholder="Type your message..."
            value={input}
            onChange={(event) => setInput(event.target.value)}
            maxLength={300}
          />
          <button type="submit" className={styles.sendButton} aria-label="Send message" disabled={sending}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" aria-hidden="true">
              <path d="M41.353846 876.307692l86.646154-320.984615h366.276923c9.846154 0 19.692308-9.846154 19.692308-19.692308v-39.384615c0-9.846154-9.846154-19.692308-19.692308-19.692308H128l-84.676923-315.076923C41.353846 157.538462 39.384615 151.630769 39.384615 145.723077c0-13.784615 13.784615-27.569231 29.538462-25.6 3.938462 0 5.907692 1.969231 9.846154 1.969231l886.153846 364.307692c11.815385 3.938462 19.692308 15.753846 19.692308 27.569231s-7.876923 21.661538-17.723077 25.6L78.769231 913.723077c-3.938462 1.969231-7.876923 1.969231-11.815385 1.969231-15.753846-1.969231-27.569231-13.784615-27.569231-29.538462 0-3.938462 0-5.907692 1.969231-9.846154z" />
            </svg>
          </button>
        </form>
      </section>
    </>
  );
}
