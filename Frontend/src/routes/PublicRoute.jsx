import React from "react";
import { Navigate, Outlet } from "react-router-dom";
import { useAuthStore } from "../store/Shared/Store";

export default function PublicRoute({ children }) {
  const isAuthed =
    !!useAuthStore.getState().accessToken &&
    useAuthStore.getState().isAuthenticated();

  if (isAuthed) return <Navigate to="/dashboard" replace />;

  return children ?? <Outlet />;
}
