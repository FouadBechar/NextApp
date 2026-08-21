"use client";

import { useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';

interface ModalProps {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
  ariaLabel?: string;
}

// Small focus-trap helper: find first/last focusable element
function getFocusableElements(container: HTMLElement | null) {
  if (!container) return [] as HTMLElement[];
  const selectors = [
    'a[href]',
    'area[href]',
    'input:not([disabled])',
    'select:not([disabled])',
    'textarea:not([disabled])',
    'button:not([disabled])',
    'iframe',
    'object',
    'embed',
    '[tabindex]:not([tabindex="-1"])',
    '[contenteditable]'
  ].join(',');
  const nodes = Array.from(container.querySelectorAll<HTMLElement>(selectors));
  return nodes.filter((n) => !n.hasAttribute('disabled') && n.getAttribute('aria-hidden') !== 'true');
}

export default function Modal({ open, onClose, children, ariaLabel = 'Dialog' }: ModalProps) {
  const overlayRef = useRef<HTMLDivElement | null>(null);
  const contentRef = useRef<HTMLDivElement | null>(null);
  const closeButtonRef = useRef<HTMLButtonElement | null>(null);
  const previouslyFocusedRef = useRef<HTMLElement | null>(null);
  const onCloseRef = useRef(onClose);

  // Keep latest onClose in ref so we don't have to include it in the effect deps.
  useEffect(() => {
    onCloseRef.current = onClose;
  }, [onClose]);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onCloseRef.current();
      if (e.key === 'Tab') {
        // basic focus trap
        const container = contentRef.current;
        const focusable = getFocusableElements(container);
        if (focusable.length === 0) return;
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (e.shiftKey) {
          if (document.activeElement === first) {
            e.preventDefault();
            last.focus();
          }
        } else {
          if (document.activeElement === last) {
            e.preventDefault();
            first.focus();
          }
        }
      }
    }

    if (open) {
      document.addEventListener('keydown', onKey);
      // remember previously focused element so we can restore focus on close
      previouslyFocusedRef.current = document.activeElement as HTMLElement | null;
      // prevent background scroll
      document.body.style.overflow = 'hidden';
      // focus the close button when opened only if focus is not already within the modal
      setTimeout(() => {
        const active = document.activeElement as HTMLElement | null;
        if (!contentRef.current?.contains(active)) closeButtonRef.current?.focus();
      }, 0);
      // Hide the main app/content from assistive tech while modal is open
      try {
        const appRoot = document.getElementById('__next') || document.querySelector('main') as HTMLElement | null;
        if (appRoot) appRoot.setAttribute('inert', '');
      } catch (e) {
        /* ignore */
      }
    }
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = '';
      // restore focus to previously focused element if available
      try {
        previouslyFocusedRef.current?.focus();
      } catch (e) {
        /* ignore */
      }
      // remove aria-hidden from main app
      try {
        const appRoot = document.getElementById('__next') || document.querySelector('main') as HTMLElement | null;
        if (appRoot) appRoot.removeAttribute('inert');
      } catch (e) {
        /* ignore */
      }
    };
    // Only re-run when `open` changes; don't include onClose to avoid restoring focus
    // during parent re-renders when a new onClose callback is passed.
  }, [open]);
  // Render into document.body to avoid stacking/context issues. Use AnimatePresence
  // so exit animations can play when `open` becomes false.
  if (typeof document === 'undefined') return null;

  const modal = (
    <AnimatePresence>
      {open && (
        <div
          ref={overlayRef}
          role="presentation"
          className="fixed inset-0 z-50 flex items-center justify-center px-4"
        >
          <motion.div
            role="dialog"
            aria-modal="true"
            aria-label={ariaLabel}
            className="absolute inset-0 bg-black/50 backdrop-blur-sm"
            onClick={() => onClose()}
            aria-hidden
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.18 }}
          />

          <div className="relative z-10 w-full max-w-3xl mx-auto">
            <motion.div
              ref={contentRef}
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.98 }}
              transition={{ duration: 0.12 }}
              className="bg-card rounded-lg shadow-lg overflow-hidden"
            >
              <div className="flex justify-end p-2">
                <button
                  ref={closeButtonRef}
                  onClick={onClose}
                  aria-label="Close dialog"
                  className="inline-flex items-center justify-center rounded-md p-2 hover:bg-muted"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                </button>
              </div>
              <div className="p-4">{children}</div>
            </motion.div>
          </div>
        </div>
      )}
    </AnimatePresence>
  );

  return ReactDOM.createPortal(modal, document.body);
}