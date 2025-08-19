import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

/* ────────────────────────────── Constants ────────────────────────────── */

const STORAGE_KEY = "auth-storage";
const REFRESH_URL = "/auth/refresh"; // change to "/api/auth/refresh" if needed
const ACCESS_REFRESH_THRESHOLD_MS = 2 * 60 * 1000; // 2 minutes

/* ──────────────────────────── Small utilities ─────────────────────────── */

/** Parses an ISO date string into a Unix ms timestamp; returns null if falsy. */
const toMs = (iso) => (iso ? new Date(iso).getTime() : null);

/**
 * Normalize API payloads into the session shape the store expects.
 * Accepts either:
 *   - { data: {...} }
 *   - plain {...}
 * and tolerates different field names (e.g., token vs accessToken).
 */
function defaultExtractor(input) {
  const d = input && input.data ? input.data : input || {};

  // Normalize roles into a string[] (supports array or comma-separated string)
  const normalizedRoles = Array.isArray(d.roles)
    ? d.roles
    : typeof d.roles === "string"
    ? d.roles
        .split(",")
        .map((x) => x.trim())
        .filter(Boolean)
    : [];

  // Normalize departments into a string[] (supports array or comma-separated string)
  const normalizedDepts = Array.isArray(d.departments)
    ? d.departments.map(String)
    : typeof d.departments === "string"
    ? d.departments
        .split(",")
        .map((x) => x.trim())
        .filter(Boolean)
    : [];

  return {
    accessToken: d.accessToken ?? d.token ?? null,
    accessExpires: d.accessExpires ?? null, // ISO string
    refreshToken: d.refreshToken ?? null,
    refreshExpires: d.refreshExpires ?? null, // ISO string
    roles: normalizedRoles,
    departments: normalizedDepts,
    user: d.user ?? null,
  };
}

/* ──────────────────────────────── Store ──────────────────────────────── */

export const useAuthStore = create(
  persist(
    (set, get) => ({
      /* ---------- persisted auth state ---------- */
      accessToken: null,
      accessExpires: null, // ISO
      refreshToken: null,
      refreshExpires: null, // ISO
      roles: [],
      departments: [],
      user: null,

      /* ---------- volatile (not persisted) ---------- */
      error: null,

      /* ---------- derived helpers ---------- */
      /**
       * Returns true if we have an accessToken and (no expiry provided OR not expired yet).
       * If backend doesn't provide accessExpires, we treat it as valid until told otherwise.
       */
      isAuthenticated: () => {
        const { accessToken, accessExpires } = get();
        if (!accessToken) return false;
        const expMs = toMs(accessExpires);
        return expMs === null ? true : expMs > Date.now();
      },

      /* ---------- setters / clearers ---------- */

      /**
       * Merge new session fields into current state.
       * Any field not present in `session` keeps the previous value.
       */
      setSession: (session = {}) =>
        set((prev) => ({
          accessToken: session.accessToken ?? prev.accessToken,
          accessExpires: session.accessExpires ?? prev.accessExpires,
          refreshToken: session.refreshToken ?? prev.refreshToken,
          refreshExpires: session.refreshExpires ?? prev.refreshExpires,
          roles: session.roles ?? prev.roles,
          departments: session.departments ?? prev.departments,
          user: session.user ?? prev.user,
          error: null,
        })),

      /** Fully clears the auth state (logout). */
      clearSession: () =>
        set({
          accessToken: null,
          accessExpires: null,
          refreshToken: null,
          refreshExpires: null,
          roles: [],
          departments: [],
          user: null,
          error: null,
        }),

      /** Alias for convenience; used elsewhere in your app. */
      logout: () => get().clearSession(),

      /** Error helpers */
      setError: (msg) => set({ error: msg ?? null }),
      clearError: () => set({ error: null }),

      /**
       * Apply an API response into the store.
       * Accepts an optional custom extractor; falls back to defaultExtractor.
       */
      applyFromApi: (payload, extractor) => {
        const session = (extractor || defaultExtractor)(payload);
        get().setSession(session);
      },

      /* ---------- token refresh logic ---------- */

      /**
       * Requests a new access token using the current refresh token.
       * Uses `fetch` to avoid axios interceptor recursion.
       * Updates the store on success and returns the new accessToken.
       */
      async refreshAccessToken() {
        const { refreshToken } = get();
        if (!refreshToken) throw new Error("No refresh token");

        const res = await fetch(REFRESH_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refreshToken }),
          credentials: "include", // harmless if you don't use cookies; required if you do
        });

        if (!res.ok) throw new Error(`Refresh failed (${res.status})`);
        const json = await res.json();

        // Support both { success, data } and plain payloads
        const payload = Object.prototype.hasOwnProperty.call(json, "success")
          ? json
          : { data: json };

        get().applyFromApi(payload);
        return get().accessToken;
      },

      /**
       * Ensures a valid access token before requests / on app gates.
       * - If no tokens: do nothing (gate/guards will redirect elsewhere).
       * - If refresh token missing/expired: logout and throw.
       * - If access token missing/near expiry: refresh it.
       */
      async refreshTokenIfNeeded() {
        const { accessToken, accessExpires, refreshToken, refreshExpires } =
          get();

        // Nothing stored → let the caller handle unauthenticated flow
        if (!accessToken && !refreshToken) return;

        // If refresh token is missing or expired → hard logout (cannot recover)
        const refreshExpMs = toMs(refreshExpires);
        if (
          !refreshToken ||
          (refreshExpMs !== null && refreshExpMs <= Date.now())
        ) {
          get().logout();
          throw new Error("Refresh token expired");
        }

        // If access token is missing OR expiring soon → refresh it
        const accessExpMs = toMs(accessExpires);
        const needsRefresh =
          !accessToken ||
          accessExpMs === null ||
          accessExpMs - Date.now() <= ACCESS_REFRESH_THRESHOLD_MS;

        if (needsRefresh) {
          await get().refreshAccessToken();
        }
      },

      /* ---------- selectors ---------- */
      hasRole: (role) => get().roles.includes(role),
      hasAnyRole: (roles = []) => roles.some((r) => get().roles.includes(r)),
      hasDepartment: (dept) => get().departments.includes(String(dept)),
      hasAnyDepartment: (depts = []) =>
        depts.some((d) => get().departments.includes(String(d))),
    }),
    {
      name: STORAGE_KEY,
      storage: createJSONStorage(() => localStorage),
      version: 3,
      // Persist only these fields
      partialize: (s) => ({
        accessToken: s.accessToken,
        accessExpires: s.accessExpires,
        refreshToken: s.refreshToken,
        refreshExpires: s.refreshExpires,
        roles: s.roles,
        departments: s.departments,
        user: s.user,
      }),
    }
  )
);
