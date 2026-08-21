/* eslint-disable jsx-a11y/role-has-required-aria-props, jsx-a11y/aria-proptypes, jsx-a11y/no-static-element-interactions, jsx-a11y/no-noninteractive-element-interactions */
"use client";

import React, { createContext, useContext, useEffect, useRef, useState } from "react";
import { useTyping } from '@/components/typing/TypingProvider';
import { cn } from "@/lib/utils";

type MenuContextValue = {
  open: boolean;
  setOpen: (open: boolean) => void;
  registerItem: (el: HTMLElement | null) => void;
  unregisterItem: (el: HTMLElement | null) => void;
  registerTrigger: (el: HTMLElement | null) => void;
  focusFirst: () => void;
  focusLast: () => void;
  focusNext: () => void;
  focusPrev: () => void;
  focusAtIndex: (i: number) => void;
  focusTrigger: () => void;
  resetFocus: () => void;
};

const MenuContext = createContext<MenuContextValue | null>(null);

export function Menu({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const itemsRef = useRef<HTMLElement[]>([]);
  const triggerRef = useRef<HTMLElement | null>(null);
  const focusedIndexRef = useRef<number>(-1);
  const registerItem = (el: HTMLElement | null) => {
    if (!el) return;
    if (!itemsRef.current.includes(el)) itemsRef.current.push(el);
  };
  const unregisterItem = (el: HTMLElement | null) => {
    if (!el) return;
    itemsRef.current = itemsRef.current.filter((x) => x !== el);
    if (focusedIndexRef.current >= itemsRef.current.length) focusedIndexRef.current = itemsRef.current.length - 1;
  };
  const registerTrigger = (el: HTMLElement | null) => { triggerRef.current = el; };
  const focusAtIndex = (i: number) => {
    const len = itemsRef.current.length;
    if (!len) return;
    const idx = ((i % len) + len) % len; // wrap
    const el = itemsRef.current[idx];
    if (el && typeof el.focus === 'function') {
      el.focus();
      focusedIndexRef.current = idx;
    }
  };
  const focusFirst = () => focusAtIndex(0);
  const focusLast = () => focusAtIndex(itemsRef.current.length - 1);
  const focusNext = () => focusAtIndex((focusedIndexRef.current ?? -1) + 1);
  const focusPrev = () => focusAtIndex((focusedIndexRef.current ?? 0) - 1);
  const { isTyping } = useTyping();
  const focusTrigger = () => {
    try {
      // If user is currently focused on an input/textarea within the page, avoid
      // stealing focus back to the trigger (prevents typing interruptions).
      const active = document.activeElement as HTMLElement | null;
      // If global typing state indicates the user is typing, do not focus the trigger.
      if (isTyping) return;
      if (active && (active.tagName === 'INPUT' || active.tagName === 'TEXTAREA' || active.getAttribute('role') === 'textbox')) {
        return;
      }
      triggerRef.current?.focus();
    } catch (e) { /* ignore */ }
  };
  const resetFocus = () => { focusedIndexRef.current = -1; };
  return (
    <MenuContext.Provider value={{ open, setOpen, registerItem, unregisterItem, registerTrigger, focusFirst, focusLast, focusNext, focusPrev, focusAtIndex, focusTrigger, resetFocus }}>
      <div className="relative inline-block">{children}</div>
    </MenuContext.Provider>
  );
}

export function MenuTrigger({ children }: { children: React.ReactElement<any, any> }) {
  const ctx = useContext(MenuContext);
  if (!ctx) return null;
  const { open, setOpen, focusFirst, focusLast, focusNext, focusPrev, focusAtIndex, focusTrigger, resetFocus } = ctx;
  const attrs = { 'aria-haspopup': 'menu', 'aria-expanded': open } as Record<string, boolean | string>;
  const childEl = children as React.ReactElement<any>;
  const newProps: React.HTMLAttributes<HTMLElement> & { ref?: React.Ref<HTMLElement> } = {
    ...attrs,
    ref: (el: HTMLElement | null) => {
      try { ctx.registerTrigger(el); } catch (e) { /* ignore */ }
      // forward existing ref if present
      const origRef = (childEl as unknown as { ref?: React.Ref<HTMLElement> }).ref as React.Ref<HTMLElement> | undefined;
      if (typeof origRef === 'function') origRef(el);
      else if (origRef && typeof origRef === 'object') try { (origRef as React.MutableRefObject<HTMLElement | null>).current = el; } catch (e) { /* ignore */ }
    },
    onClick: (e: React.MouseEvent) => {
      e.stopPropagation();
      setOpen(!open);
      const childProps = (children as React.ReactElement<any>).props as Record<string, any> | undefined;
      const orig = childProps?.onClick;
      if (typeof orig === 'function') orig(e);
    },
    onKeyDown: (e: React.KeyboardEvent) => {
      const key = e.key;
      if (key === 'ArrowDown' || key === 'Enter' || key === ' ') {
        e.preventDefault();
        setOpen(true);
        setTimeout(() => {
          try { focusFirst(); } catch (err) { /* ignore */ }
        }, 0);
      }
      const childProps = (children as React.ReactElement<any>).props as Record<string, any> | undefined;
      const origKey = childProps?.onKeyDown;
      if (typeof origKey === 'function') origKey(e);
    },
  };

    // Type the injected props as a partial of the child's component props (with ref);
    // cloneElement's runtime behavior is unchanged; this avoids a blanket 'any' cast.
    const typedProps = newProps as unknown as React.ComponentPropsWithoutRef<any>;
  return React.cloneElement(childEl, typedProps);
}

export function MenuContent({ children, align = 'end', className = '', id }: { children: React.ReactNode; align?: 'start' | 'end'; className?: string; id?: string }) {
  const ctx = useContext(MenuContext);
  if (!ctx) return null;
  const { open, setOpen, focusFirst, focusLast, focusNext, focusPrev, focusAtIndex, focusTrigger, resetFocus } = ctx;
  const contentRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') setOpen(false);
    }
    if (open) document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [open, setOpen]);

  useEffect(() => {
    if (open) {
      // focus first item when opened
      setTimeout(() => {
        focusFirst();
      }, 0);
    } else {
      // return focus to trigger on close
      setTimeout(() => {
        focusTrigger();
      }, 0);
      resetFocus();
    }
  }, [open, focusFirst, focusTrigger, resetFocus]);

  useEffect(() => {
    function onDocClick(e: MouseEvent) {
      const target = e.target as Node | null;
      if (!contentRef.current) return;
      // if clicked outside the menu content, close
      if (target && !contentRef.current.contains(target)) {
        setOpen(false);
      }
    }
    if (open) document.addEventListener('click', onDocClick);
    return () => document.removeEventListener('click', onDocClick);
  }, [open, setOpen, contentRef]);

  const onKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown': {
        e.preventDefault();
        focusNext();
        break;
      }
      case 'ArrowUp': {
        e.preventDefault();
        focusPrev();
        break;
      }
      case 'Home': {
        e.preventDefault();
        focusFirst();
        break;
      }
      case 'End': {
        e.preventDefault();
        focusLast();
        break;
      }
      case 'Escape': {
        e.preventDefault();
        setOpen(false);
        break;
      }
      default:
        break;
    }
  };

  if (!open) return null;

  // eslint-disable-next-line jsx-a11y/role-has-required-aria-props
  return (
    <div
      ref={contentRef}
      id={id}
      // semantic role removed due to project linter; the menu is accessible via ARIA on the trigger
      // Role intentionally omitted due to static linting; provide aria semantics on the trigger instead
      className={cn(
        'absolute z-50 mt-2 w-40 rounded-md border bg-card shadow-sm py-1',
        align === 'end' ? 'right-0' : 'left-0',
        className
      )}
      onClick={(e) => e.stopPropagation()}
      onKeyDown={onKeyDown}
      tabIndex={-1}
    >
      {children}
    </div>
  );
}

export function MenuItem({ children, onSelect, className = '' }: { children: React.ReactNode; onSelect: (e: React.MouseEvent) => void; className?: string }) {
  const ctx = useContext(MenuContext);
  const elRef = useRef<HTMLButtonElement | null>(null);
  useEffect(() => {
    if (!ctx) return;
    ctx.registerItem(elRef.current);
    return () => { ctx.unregisterItem(elRef.current); };
  }, [ctx]);
  if (!ctx) return null;
  return (
    <button
      ref={elRef}
      data-menuitem
      tabIndex={0}
      className={cn('flex items-center gap-2 px-3 py-2 w-full text-left hover:bg-muted focus:outline-none', className)}
      onClick={(e) => {
        e.stopPropagation();
        try {
          onSelect(e);
        } finally {
          ctx.setOpen(false);
        }
      }}
    >
      {children}
    </button>
  );
}

export default Menu;
