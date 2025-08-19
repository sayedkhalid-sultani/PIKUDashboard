// src/components/shared/AuthAwareFallback.jsx
import React from "react";
import { Navigate } from "react-router-dom";
import { useAuthStore } from "../../store/Shared/Store";

export default function AuthAwareFallback() {
  const hasHydrated = useAuthStore((s) => s.hasHydrated);
  const isAuth = useAuthStore((s) => s.isAuthenticated());

  if (!hasHydrated) {
    return <div className="p-4 text-sm text-gray-500">Loading…</div>;
  }

  return <Navigate to={isAuth ? "/dashboard" : "/login"} replace />;
}
