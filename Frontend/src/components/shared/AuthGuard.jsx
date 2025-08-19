import { useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { useAuthStore } from "../../store/Shared/Store";

/**
 * Top-level guard used as a wrapper around your <AppRouter />.
 * - Redirects to /login when there's no valid session.
 * - Redirects to /dashboard when authed user hits /login.
 *
 * Pairs with AuthRefreshGate (which proactively refreshes tokens).
 */
export default function AuthGuard({ children }) {
  const navigate = useNavigate();
  const location = useLocation();

  // pull what we need from the store
  const accessToken = useAuthStore((s) => s.accessToken);
  const refreshToken = useAuthStore((s) => s.refreshToken);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);

  useEffect(() => {
    const onLogin = location.pathname === "/login";
    const authed = isAuthenticated();

    // No session at all (no access & no refresh) -> go to login
    if (!accessToken && !refreshToken) {
      if (!onLogin) {
        navigate("/login", { replace: true, state: { from: location } });
      }
      return;
    }

    // We have some session state. If not authenticated (expired/invalid) -> go to login
    if (!authed) {
      if (!onLogin) {
        navigate("/login", { replace: true, state: { from: location } });
      }
      return;
    }

    // Authenticated and on /login -> push to dashboard
    if (authed && onLogin) {
      navigate("/dashboard", { replace: true });
    }
  }, [accessToken, refreshToken, isAuthenticated, location, navigate]);

  // Render children by default; redirects above will replace the route when needed
  return <>{children}</>;
}
