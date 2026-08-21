import { useEffect, useRef } from "react";

interface CaretPosition {
  start: number | null;
  end: number | null;
}

interface Options {
  onFocus?: (e: React.FocusEvent<any>) => void;
  onBlur?: () => void;
}

/**
 * Manage focus and caret position for a set of named input fields.
 *
 * idMap maps a logical field name to the DOM element id that should be used
 * when attempting to restore focus after a dependency change. deps is the
 * array of values which, when changed, should trigger a focus restoration
 * attempt (e.g. [threads]).
 *
 * The hook returns a `createHandlers` helper that produces the necessary
 * props for an input/textarea (onFocus, onBlur, onSelect, id) that wire up
 * tracking.  It also invokes optional callbacks for typing state notifications.
 */
export function useInputFocusPersistence(
  idMap: Record<string, string>,
  deps: any[],
  options: Options = {}
) {
  const focusedInputRef = useRef<string | null>(null);
  const activeInputElementRef = useRef<
    HTMLInputElement | HTMLTextAreaElement | null
  >(null);
  const caretRef = useRef<Record<string, CaretPosition>>({});

  useEffect(() => {
    if (focusedInputRef.current) {
      try {
        const field = focusedInputRef.current as string;
        const currentEl =
          activeInputElementRef.current ??
          (document.getElementById(idMap[field]) as
            | HTMLInputElement
            | HTMLTextAreaElement
            | null);
        if (currentEl && document.activeElement !== currentEl) {
          setTimeout(() => {
            try {
              currentEl.focus();
              const caret = caretRef.current[field];
              if (caret && caret.start !== null) {
                try {
                  const textEl = currentEl as
                    | HTMLInputElement
                    | HTMLTextAreaElement;
                  if (typeof textEl.setSelectionRange === "function") {
                    try {
                      textEl.setSelectionRange(caret.start, caret.end ?? caret.start);
                    } catch (e) {
                      /* ignore */
                    }
                  }
                } catch (e) {
                  /* ignore */
                }
              }
            } catch (e) {
              /* ignore */
            }
          }, 0);
        }
      } catch (e) {
        // ignore
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  function createHandlers(field: string) {
    const id = idMap[field];

    return {
      id,
      onFocus: (e: React.FocusEvent<any>) => {
        focusedInputRef.current = field;
        activeInputElementRef.current = e.target as
          | HTMLInputElement
          | HTMLTextAreaElement;
        if (options.onFocus) {
          options.onFocus(e);
        }
      },
      onBlur: () => {
        if (focusedInputRef.current === field) focusedInputRef.current = null;
        activeInputElementRef.current = null;
        if (options.onBlur) {
          options.onBlur();
        }
      },
      onSelect: (e: React.SyntheticEvent<any>) => {
        try {
          const t = e.target as HTMLInputElement | HTMLTextAreaElement;
          caretRef.current[field] = {
            start: t.selectionStart ?? null,
            end: t.selectionEnd ?? null,
          };
        } catch (err) {
          /* ignore */
        }
      },
    };
  }

  return { createHandlers };
}
