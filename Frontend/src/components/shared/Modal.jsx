// src/components/shared/Modal.jsx
import React, { useEffect, useRef, useMemo } from "react";
import { createPortal } from "react-dom";

export function useModal(initial = false) {
  const [open, setOpen] = React.useState(initial);
  return {
    open,
    setOpen,
    show: () => setOpen(true),
    hide: () => setOpen(false),
    toggle: () => setOpen((v) => !v),
  };
}

const sizes = {
  sm: "max-w-md",
  md: "max-w-lg",
  lg: "max-w-2xl",
  xl: "max-w-4xl",
  full: "max-w-[95vw] h-[95vh]",
  // "auto" handled below
};

function ensureRoot() {
  let el = document.getElementById("modal-root");
  if (!el) {
    el = document.createElement("div");
    el.id = "modal-root";
    document.body.appendChild(el);
  }
  return el;
}

const resolve = (maybe, ctx) =>
  typeof maybe === "function" ? maybe(ctx) : maybe;

export default function Modal({
  open,
  onClose,
  title,
  subtitle,
  size = "md", // "auto" | "sm" | "md" | "lg" | "xl" | "full"
  showClose = true,
  closeOnOverlayClick = false, // keep modal until ✕ unless you flip this
  closeOnEsc = false,
  initialFocusRef,

  // One of:
  children,
  component: Component,
  componentProps = {},
}) {
  const panelRef = useRef(null);
  const closeBtnRef = useRef(null);
  const rootRef = useRef(null);
  if (!rootRef.current) rootRef.current = ensureRoot();

  // Lock body scroll (with scrollbar compensation)
  useEffect(() => {
    if (!open) return;
    const prevOverflow = document.body.style.overflow;
    const prevPadRight = document.body.style.paddingRight;
    const sbw = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (sbw > 0) document.body.style.paddingRight = `${sbw}px`;
    return () => {
      document.body.style.overflow = prevOverflow;
      document.body.style.paddingRight = prevPadRight;
    };
  }, [open]);

  // Focus, Esc, and simple focus trap
  useEffect(() => {
    if (!open) return;
    const prevActive = document.activeElement;

    const toFocus =
      initialFocusRef?.current ||
      panelRef.current?.querySelector("[data-autofocus]") ||
      closeBtnRef.current ||
      panelRef.current;
    toFocus?.focus();

    const handleKey = (e) => {
      if (e.key === "Escape" && closeOnEsc) {
        e.stopPropagation();
        onClose?.();
      }
      if (e.key === "Tab") {
        const focusables = panelRef.current?.querySelectorAll(
          'a[href],button:not([disabled]),textarea,input,select,[tabindex]:not([tabindex="-1"])'
        );
        if (!focusables || focusables.length === 0) return;
        const list = Array.from(focusables);
        const first = list[0];
        const last = list[list.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", handleKey, true);
    return () => {
      document.removeEventListener("keydown", handleKey, true);
      if (prevActive && prevActive.focus) prevActive.focus();
    };
  }, [open, onClose, initialFocusRef, closeOnEsc]);

  // Compute (hooks before any early return)
  const ctx = useMemo(
    () => ({ open, onClose, componentProps }),
    [open, onClose, componentProps]
  );
  const headerTitle = resolve(title, ctx);
  const headerSubtitle = resolve(subtitle, ctx);
  const content =
    children ?? (Component ? <Component {...componentProps} /> : null);

  if (!open) return null;

  // Dynamic sizing
  const panelWidthClass =
    size === "auto"
      ? "w-auto inline-block max-w-[95vw]"
      : `w-full ${sizes[size] ?? sizes.md}`;

  const bodyHeightClass =
    size === "full"
      ? "overflow-auto h-[calc(95vh-7rem)]"
      : "max-h-[80vh] overflow-auto";

  return createPortal(
    <div
      className="fixed inset-0 z-[1000] flex items-center justify-center"
      aria-modal="true"
      role="dialog"
      aria-labelledby="modal-title"
      onMouseDown={(e) => {
        if (!closeOnOverlayClick) return;
        if (e.target === e.currentTarget) onClose?.();
      }}
    >
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/50 animate-fadeIn" />

      {/* Panel */}
      <div
        ref={panelRef}
        className={`relative z-10 ${panelWidthClass} mx-4 rounded-2xl bg-white shadow-2xl outline-none animate-scaleIn`}
        tabIndex={-1}
      >
        {(headerTitle || showClose) && (
          <div className="flex items-start gap-4 p-4 border-b">
            <div className="flex-1">
              {headerTitle && (
                <h2
                  id="modal-title"
                  className="text-lg font-semibold text-slate-900"
                >
                  {headerTitle}
                </h2>
              )}
              {headerSubtitle && (
                <p className="mt-0.5 text-sm text-slate-500">
                  {headerSubtitle}
                </p>
              )}
            </div>

            {showClose && (
              <button
                ref={closeBtnRef}
                onClick={onClose}
                aria-label="Close"
                className="inline-flex h-11 w-11 items-center justify-center rounded-full
                           text-red-600 text-2xl leading-none
                           hover:text-red-700 hover:bg-red-50
                           focus-visible:ring-2 focus-visible:ring-red-500"
                title="Close"
              >
                ✕
              </button>
            )}
          </div>
        )}

        {/* Body */}
        <div className={`p-4 ${bodyHeightClass}`}>{content}</div>
      </div>

      {/* Tiny animations */}
      <style>{`
        .animate-fadeIn { animation: fadeIn .15s ease-out; }
        .animate-scaleIn { animation: scaleIn .18s ease-out; }
        @keyframes fadeIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes scaleIn { from { opacity: 0; transform: translateY(4px) scale(.98) } to { opacity: 1; transform: translateY(0) scale(1) } }
      `}</style>
    </div>,
    rootRef.current
  );
}
