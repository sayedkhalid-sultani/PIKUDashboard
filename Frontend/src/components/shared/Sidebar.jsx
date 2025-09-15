// src/components/shared/Sidebar.jsx
import React from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useAuthStore } from "../../store/Shared/Store";

const linkClasses = ({ isActive }) =>
  `block rounded px-3 py-2 text-sm transition ${isActive
    ? "bg-blue-50 text-blue-700 font-semibold"
    : "text-slate-700 hover:bg-slate-100"
  }`;

const Sidebar = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const clearSession = useAuthStore((s) => s.clearSession);
  const isAdmin = useAuthStore((s) => s.hasRole("Admin"));

  const handleLogout = () => {
    clearSession();
    queryClient.clear();
    navigate("/login", { replace: true });
  };

  return (
    <aside className="w-64 bg-gray-100 p-6 flex flex-col h-full border-r border-gray-200">
      <nav className="space-y-2 flex-1">
        {/* Dashboard root */}
        <NavLink to="/dashboard" end className={linkClasses}>
          Dashboard
        </NavLink>

        {/* Dashboard children */}
        <div className="flex flex-col space-y-1 pl-3 mt-1 border-l border-gray-200">
          <NavLink to="dashboard/CountryDashboard" end className={linkClasses}>
            Country Dashboard
          </NavLink>
          <NavLink to="/dashboard/Map" className={linkClasses}>
            Country Map
          </NavLink>
          <NavLink to="/dashboard/CountryProfile" className={linkClasses}>
            Country Profile
          </NavLink>
          <NavLink to="/dashboard/CountryProfilemui" className={linkClasses}>
            Country Profile mui
          </NavLink>
          <NavLink to="/dashboard/Analyze" className={linkClasses}>
            Analyze
          </NavLink>
        </div>

        {/* Change Password */}
        <NavLink to="/change-password" className={linkClasses}>
          Change Password
        </NavLink>

        {/* Admin area */}
        {isAdmin && (
          <>
            <div className="mt-3 text-xs font-semibold uppercase text-slate-500 px-3">
              Admin
            </div>
            <div className="ml-0 pl-3 border-l border-gray-200 flex flex-col space-y-1 mt-1">
              <NavLink to="/admin/indicators" className={linkClasses}>
                Indicators
              </NavLink>
              <NavLink to="/admin/users" className={linkClasses} end>
                Users
              </NavLink>
            </div>
          </>
        )}
      </nav>

      <button
        onClick={handleLogout}
        className="mt-auto rounded border px-3 py-2 text-sm font-medium hover:bg-gray-200"
      >
        Logout
      </button>
    </aside>
  );
};

export default Sidebar;
