import React from "react";
import { Navigate } from "react-router-dom";
import { useAuthStore } from "../store/Shared/Store";

export default function HomeRedirect() {
  const isAuthed =
    !!useAuthStore.getState().accessToken &&
    useAuthStore.getState().isAuthenticated();

  return isAuthed ? (
    <Navigate to="/dashboard" replace />
  ) : (
    <Navigate to="/login" replace />
  );
}
