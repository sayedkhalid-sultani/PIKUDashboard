// src/components/shared/Spinner.jsx
import { useIsFetching, useIsMutating } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import { ClipLoader } from "react-spinners";

// Ignore these keys in the global overlay
const IGNORED_MUTATION_KEYS = [["login"]]; // add more: e.g., ["changePassword"]
const IGNORED_QUERY_KEYS = []; // e.g., [["me"]]

const SHOW_DELAY_MS = 250; // wait before showing
const MIN_VISIBLE_MS = 300; // keep visible at least this long

function isSameKey(a, b) {
  if (!Array.isArray(b) || a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) return false;
  }
  return true;
}

export default function Spinner() {
  // Count active queries (excluding ignored)
  const isFetching = useIsFetching({
    predicate(q) {
      const key = q.queryKey || [];
      return !IGNORED_QUERY_KEYS.some((ignore) => isSameKey(ignore, key));
    },
  });

  // Count active mutations (excluding ignored)
  const isMutating = useIsMutating({
    predicate(m) {
      const key = (m.options && m.options.mutationKey) || [];
      return !IGNORED_MUTATION_KEYS.some((ignore) => isSameKey(ignore, key));
    },
  });

  const pending = isFetching + isMutating > 0;

  // Debounce + min-visible logic
  const [visible, setVisible] = useState(false);
  const shownAtRef = useRef(0);
  const delayTimer = useRef(null);
  const minTimer = useRef(null);

  useEffect(() => {
    return () => {
      if (delayTimer.current) clearTimeout(delayTimer.current);
      if (minTimer.current) clearTimeout(minTimer.current);
    };
  }, []);

  useEffect(() => {
    if (pending) {
      if (!visible && !delayTimer.current) {
        delayTimer.current = setTimeout(() => {
          delayTimer.current = null;
          setVisible(true);
          shownAtRef.current = performance.now();
        }, SHOW_DELAY_MS);
      }
    } else {
      // cancel pending show
      if (delayTimer.current) {
        clearTimeout(delayTimer.current);
        delayTimer.current = null;
      }
      // enforce min visible time
      if (visible) {
        const elapsed = performance.now() - shownAtRef.current;
        const remain = Math.max(0, MIN_VISIBLE_MS - elapsed);
        if (remain > 0) {
          if (!minTimer.current) {
            minTimer.current = setTimeout(() => {
              minTimer.current = null;
              setVisible(false);
            }, remain);
          }
        } else {
          setVisible(false);
        }
      }
    }
  }, [pending, visible]);

  if (!visible) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20">
      <ClipLoader size={60} />
    </div>
  );
}
