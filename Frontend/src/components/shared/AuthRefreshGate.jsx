// src/components/shared/AuthRefreshGate.jsx
import { useEffect, useRef } from "react";
import { useAuthStore } from "../../store/Shared/Store";
import { useQueryClient } from "@tanstack/react-query";
import { useNavigate, useLocation } from "react-router-dom";

export default function AuthRefreshGate() {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const location = useLocation();

  const refreshOnceTried = useRef(false);
  const {
    accessToken,
    refreshToken,
    isAuthenticated,
    refreshTokenIfNeeded,
    refreshAccessToken,
    logout,
  } = useAuthStore();

  // ==== existing "strict login check" effect (unchanged) ====
  useEffect(() => {
    const ensureLoggedIn = async () => {
      const authed = isAuthenticated();

      if (!accessToken) {
        if (!refreshOnceTried.current && refreshToken) {
          try {
            refreshOnceTried.current = true;
            await refreshAccessToken();
            return;
          } catch {}
        }
        if (location.pathname !== "/login") {
          logout();
          navigate("/login", { replace: true, state: { from: location } });
        }
        return;
      }

      try {
        await refreshTokenIfNeeded?.();
      } catch {
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };

    ensureLoggedIn();
  }, [
    accessToken,
    refreshToken,
    isAuthenticated,
    refreshTokenIfNeeded,
    refreshAccessToken,
    logout,
    navigate,
    location,
  ]);

  // ==== NEW: re-check whenever the route changes ====
  useEffect(() => {
    let alive = true;
    const onRouteChangeCheck = async () => {
      try {
        await refreshTokenIfNeeded?.();
        if (!useAuthStore.getState().isAuthenticated()) {
          throw new Error("Not authenticated");
        }
      } catch {
        if (!alive) return;
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };
    onRouteChangeCheck();
    return () => {
      alive = false;
    };
  }, [location.pathname, refreshTokenIfNeeded, logout, navigate, location]);

  // ==== existing proactive checks + RQ nudges (unchanged) ====
  useEffect(() => {
    let timer;
    const check = async () => {
      try {
        await refreshTokenIfNeeded?.();
      } catch {
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };
    const onFocus = () => check();
    const onOnline = () => check();
    window.addEventListener("focus", onFocus);
    window.addEventListener("online", onOnline);
    timer = window.setInterval(check, 30_000);
    const onStorage = (e) => {
      if (e.key === "auth-storage" && e.newValue === null) {
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };
    window.addEventListener("storage", onStorage);
    return () => {
      window.removeEventListener("focus", onFocus);
      window.removeEventListener("online", onOnline);
      window.removeEventListener("storage", onStorage);
      if (timer) window.clearInterval(timer);
    };
  }, [refreshTokenIfNeeded, logout, navigate, location]);

  useEffect(() => {
    const unsubQ = queryClient.getQueryCache().subscribe(() => {
      refreshTokenIfNeeded?.();
    });
    const unsubM = queryClient.getMutationCache().subscribe(() => {
      refreshTokenIfNeeded?.();
    });
    return () => {
      unsubQ();
      unsubM();
    };
  }, [queryClient, refreshTokenIfNeeded]);

  return null;
}
