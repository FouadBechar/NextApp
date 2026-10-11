// @vitest-environment jsdom
import { act } from "react";
import { createRoot, type Root } from "react-dom/client";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import ChatWidget from "../../components/ChatWidget";

describe("ChatWidget", () => {
  let container: HTMLDivElement;
  let root: Root;

  beforeEach(() => {
    (globalThis as typeof globalThis & { IS_REACT_ACT_ENVIRONMENT: boolean })
      .IS_REACT_ACT_ENVIRONMENT = true;
    localStorage.setItem(
      "nextapp:chat-widget:history",
      JSON.stringify([
        { role: "system", text: "This must not be rendered or sent." },
        { role: "user", text: "Saved question" },
      ]),
    );
    container = document.createElement("div");
    document.body.append(container);
    root = createRoot(container);
  });

  afterEach(async () => {
    await act(async () => root.unmount());
    container.remove();
    localStorage.clear();
  });

  it("loads only supported history roles and manages dialog focus", async () => {
    await act(async () => {
      root.render(<ChatWidget />);
      await Promise.resolve();
    });

    expect(container.textContent).toContain("Saved question");
    expect(container.textContent).not.toContain("This must not be rendered or sent.");

    const toggle = container.querySelector<HTMLButtonElement>('button[aria-label="Open chat"]');
    expect(toggle).not.toBeNull();

    await act(async () => {
      toggle?.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    });

    const input = container.querySelector<HTMLInputElement>('input[aria-label="Message to NextApp assistant"]');
    expect(toggle?.getAttribute("aria-expanded")).toBe("true");
    expect(document.activeElement).toBe(input);

    await act(async () => {
      window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
    });

    expect(toggle?.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(toggle);
  });
});
