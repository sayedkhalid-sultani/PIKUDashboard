// src/components/shared/AuthRefreshGate.jsx
import { useEffect, useRef } from "react";
import { useAuthStore } from "../../store/Shared/Store";
import { useQueryClient } from "@tanstack/react-query";
import { useNavigate, useLocation } from "react-router-dom";

export default function AuthRefreshGate() {
  // Hooks for navigation, location, and react-query
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const location = useLocation();

  // Auth store values and actions
  const refreshOnceTried = useRef(false);
  const {
    accessToken,
    refreshToken,
    refreshTokenIfNeeded,
    refreshAccessToken,
    logout,
  } = useAuthStore();

  // Effect 1: Strict login check on mount and when tokens change
  useEffect(() => {
    const checkAuth = async () => {
      if (!accessToken) {
        // Try refresh once if we have a refresh token
        if (!refreshOnceTried.current && refreshToken) {
          try {
            refreshOnceTried.current = true;
            await refreshAccessToken();
            return;
          } catch {}
        }
        // Redirect to login if not authenticated
        if (location.pathname !== "/login") {
          logout();
          navigate("/login", { replace: true, state: { from: location } });
        }
        return;
      }
      // Proactively refresh token if needed
      try {
        await refreshTokenIfNeeded?.();
      } catch {
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };
    checkAuth();
  }, [
    accessToken,
    refreshToken,
    refreshAccessToken,
    refreshTokenIfNeeded,
    logout,
    navigate,
    location,
  ]);

  // Effect 2: Re-check authentication whenever route changes
  useEffect(() => {
    let alive = true;
    const checkRouteAuth = async () => {
      try {
        await refreshTokenIfNeeded?.();
        if (!useAuthStore.getState().isAuthenticated())
          throw new Error("Not authenticated");
      } catch {
        if (!alive) return;
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    };
    checkRouteAuth();
    return () => {
      alive = false;
    };
  }, [location.pathname, refreshTokenIfNeeded, logout, navigate, location]);

  // Effect 3: Proactive checks on focus, online, interval, and localStorage changes
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
    window.addEventListener("focus", check);
    window.addEventListener("online", check);
    timer = window.setInterval(check, 30000);
    window.addEventListener("storage", (e) => {
      if (e.key === "auth-storage" && e.newValue === null) {
        logout();
        if (location.pathname !== "/login") {
          navigate("/login", { replace: true, state: { from: location } });
        }
      }
    });
    return () => {
      window.removeEventListener("focus", check);
      window.removeEventListener("online", check);
      window.removeEventListener("storage", check);
      if (timer) window.clearInterval(timer);
    };
  }, [refreshTokenIfNeeded, logout, navigate, location]);

  // Effect 4: React-query cache/mutation changes trigger token refresh
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

  // This gate does not render anything
  return null;
}
