// src/routes/PrivateRoute.jsx
import React, { useEffect, useRef, useState } from "react";
import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuthStore } from "../store/Shared/Store";

export default function PrivateRoute({
  roles,
  depts,
  redirectTo = "/login",
  children,
}) {
  const location = useLocation();

  const accessToken = useAuthStore((s) => s.accessToken);
  const refreshToken = useAuthStore((s) => s.refreshToken);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const refreshAccessToken = useAuthStore((s) => s.refreshAccessToken);
  const refreshTokenIfNeeded = useAuthStore((s) => s.refreshTokenIfNeeded);
  const hasRole = useAuthStore((s) => s.hasRole);
  const hasAnyDepartment = useAuthStore((s) => s.hasAnyDepartment);
  const logout = useAuthStore((s) => s.logout);

  const [status, setStatus] = useState("checking");
  const triedRefreshOnce = useRef(false);

  // NEW: hard check against persisted storage on every render/route change
  const persisted = (() => {
    try {
      const raw = localStorage.getItem("auth-storage");
      if (!raw) return null;
      const parsed = JSON.parse(raw);
      return parsed?.state?.accessToken || null;
    } catch {
      return null;
    }
  })();

  useEffect(() => {
    let cancelled = false;

    const decide = async () => {
      // If memory has token but storage doesn't, treat as logged out
      if (accessToken && !persisted) {
        logout();
        setStatus("deny");
        return;
      }

      if (!accessToken) {
        if (!triedRefreshOnce.current && refreshToken) {
          triedRefreshOnce.current = true;
          try {
            await refreshAccessToken();
            if (!cancelled) setStatus("allow");
            return;
          } catch {
            if (!cancelled) setStatus("deny");
            return;
          }
        }
        setStatus("deny");
        return;
      }

      try {
        await refreshTokenIfNeeded?.();
        const ok = isAuthenticated();
        setStatus(ok ? "allow" : "deny");
      } catch {
        setStatus("deny");
      }
    };

    setStatus("checking");
    decide();

    return () => {
      cancelled = true;
    };
    // include location.pathname so route changes re-check
  }, [
    accessToken,
    refreshToken,
    isAuthenticated,
    refreshTokenIfNeeded,
    refreshAccessToken,
    persisted,
    logout,
    location.pathname,
  ]);

  if (status === "checking") return null;
  if (status === "deny") {
    return <Navigate to={redirectTo} replace state={{ from: location }} />;
  }

  if (roles && roles.length > 0) {
    const ok = roles.some((r) => hasRole?.(r));
    if (!ok) return <Navigate to="/dashboard" replace />;
  }

  if (depts && depts.length > 0) {
    const ok = hasAnyDepartment?.(depts);
    if (!ok) return <Navigate to="/dashboard" replace />;
  }

  return children ?? <Outlet />;
}
