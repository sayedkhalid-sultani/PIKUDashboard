// src/routes/AppRouter.jsx
import React, { Suspense, lazy } from "react";
import { Routes, Route, Navigate } from "react-router-dom";

import PrivateRoute from "./PrivateRoute";
import PublicRoute from "./PublicRoute";
import HomeRedirect from "./HomeRedirect";

// --- Lazy page/layout chunks ---
const Layout = lazy(() => import("../components/shared/Layout"));

const DashboardContent = lazy(() =>
  import("../components/ui/DashboardContent")
);
const CountryProfile = lazy(() => import("../components/ui/CountryProfile"));
const CountryProfilemui = lazy(() =>
  import("../components/ui/CountryProfilemui")
);
const Analyze = lazy(() => import("../components/ui/Analyze"));

const Indicators = lazy(() => import("../components/ui/Indicators"));
const Users = lazy(() => import("../components/ui/admin/Users"));
// If you combined Register+Edit into one, point both routes to that file.
// Otherwise keep these two:
const RegisterUser = lazy(() => import("../components/ui/admin/RegisterUser"));
const EditUser = lazy(() => import("../components/ui/admin/EditUser"));

const ChangePassword = lazy(() => import("../components/ui/ChangePassword"));
const Login = lazy(() => import("../components/ui/Login"));
const AdminContent = lazy(() => import("../components/ui/AdminContent"));

// Simple route-level fallback (keep it light)
function RouteFallback() {
  return <div className="p-6 text-slate-500">Loading…</div>;
}

export default function AppRouter() {
  return (
    <Routes>
      {/* Root: send to dashboard if authed, else login */}
      <Route path="/" element={<HomeRedirect />} />

      {/* Public-only (login) */}
      <Route
        path="/login"
        element={
          <PublicRoute>
            <Suspense fallback={<RouteFallback />}>
              <Login />
            </Suspense>
          </PublicRoute>
        }
      />

      {/* Protected shell */}
      <Route
        element={
          <PrivateRoute>
            <Suspense fallback={<RouteFallback />}>
              <Layout />
            </Suspense>
          </PrivateRoute>
        }
      >
        {/* Dashboard area */}
        <Route
          path="dashboard"
          element={
            <Suspense fallback={<RouteFallback />}>
              <DashboardContent />
            </Suspense>
          }
        >
          <Route index element={<Navigate to="CountryProfile" replace />} />
          <Route
            path="CountryProfile"
            element={
              <Suspense fallback={<RouteFallback />}>
                <CountryProfile />
              </Suspense>
            }
          />

          <Route
            path="CountryProfilemui"
            element={
              <Suspense fallback={<RouteFallback />}>
                <CountryProfilemui />
              </Suspense>
            }
          />

          <Route
            path="Analyze"
            element={
              <Suspense fallback={<RouteFallback />}>
                <Analyze />
              </Suspense>
            }
          />
        </Route>

        <Route
          path="change-password"
          element={
            <Suspense fallback={<RouteFallback />}>
              <ChangePassword />
            </Suspense>
          }
        />

        {/* Admin (admin-only) */}
        <Route
          path="admin"
          element={
            <PrivateRoute roles={["Admin"]}>
              <Suspense fallback={<RouteFallback />}>
                <AdminContent />
              </Suspense>
            </PrivateRoute>
          }
        >
          <Route index element={<Navigate to="users" replace />} />
          <Route
            path="indicators"
            element={
              <Suspense fallback={<RouteFallback />}>
                <Indicators />
              </Suspense>
            }
          />
          <Route
            path="users"
            element={
              <Suspense fallback={<RouteFallback />}>
                <Users />
              </Suspense>
            }
          />
          <Route
            path="users/new"
            element={
              <Suspense fallback={<RouteFallback />}>
                <RegisterUser />
              </Suspense>
            }
          />
          <Route
            path="users/edit/:id"
            element={
              <Suspense fallback={<RouteFallback />}>
                <EditUser />
              </Suspense>
            }
          />
        </Route>
      </Route>

      {/* 404 */}
      <Route path="*" element={<div className="p-6">Not found</div>} />
    </Routes>
  );
}
