import React from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useAuthStore } from "../../store/Shared/Store";
import { FiMenu, FiX, FiHome, FiMap, FiUser, FiPieChart, FiSettings, FiLock, FiLogOut, FiGlobe, FiBarChart2 } from "react-icons/fi";

const Sidebar = ({ isOpen, toggleSidebar }) => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const clearSession = useAuthStore((s) => s.clearSession);
  const isAdmin = useAuthStore((s) => s.hasRole("Admin"));

  const handleLogout = () => {
    clearSession();
    queryClient.clear();
    navigate("/login", { replace: true });
  };

  const linkClasses = ({ isActive }) =>
    `flex items-center space-x-3 rounded-lg px-4 py-3 transition-all ${isActive
      ? "bg-blue-100 text-blue-700 font-semibold"
      : "text-gray-700 hover:bg-gray-100"
    }`;

  return (
    <aside
      className={`relative h-screen bg-white border-r border-gray-200 transition-all duration-300 ${isOpen ? "w-64" : "w-0"
        }`}
    >
      <div className={`h-full flex flex-col p-5 ${isOpen ? "block" : "hidden"}`}>
        {/* Logo */}
        <div className="flex items-center space-x-2 mb-8">
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
            <FiGlobe className="text-white text-lg" />
          </div>
          <h1 className="text-xl font-bold text-gray-800">PIKU Dashboard</h1>
        </div>

        {/* Navigation */}
        <nav className="space-y-1 flex-1">
          {/* Dashboard */}
          {/* <NavLink to="/dashboard" end className={linkClasses}>
            <FiHome className="text-lg" />
            <span>Dashboard</span>
          </NavLink> */}
          {/* Dashboard children */}
          <NavLink to="/dashboard/CountryDashboard" className={linkClasses}>
            <FiMap className="text-lg" />
            <span>Country Map</span>
          </NavLink>

          <NavLink to="/dashboard/CountryProfile" className={linkClasses}>
            <FiUser className="text-lg" />
            <span>Country Profile</span>
          </NavLink>

          <NavLink to="/dashboard/CountryProfilemui" className={linkClasses}>
            <FiUser className="text-lg" />
            <span>Country Profile MUI</span>
          </NavLink>

          <NavLink to="/dashboard/Analyze" className={linkClasses}>
            <FiPieChart className="text-lg" />
            <span>Analyze</span>
          </NavLink>

          {/* Change Password */}
          <NavLink to="/change-password" className={linkClasses}>
            <FiLock className="text-lg" />
            <span>Change Password</span>
          </NavLink>
        </nav>

        {/* Admin area */}
        {isAdmin && (
          <div className="pt-5 border-t border-gray-200">
            <h3 className="text-xs font-semibold uppercase text-gray-500 px-4 mb-3">Admin</h3>
            <div className="space-y-1">
              <NavLink to="/admin/indicators" className={linkClasses}>
                <FiSettings className="text-lg" />
                <span>Indicators</span>
              </NavLink>
              <NavLink to="/admin/users" className={linkClasses}>
                <FiUser className="text-lg" />
                <span>Users</span>
              </NavLink>
            </div>
          </div>
        )}

        {/* Logout Button */}
        <div className="mt-5">
          <button
            onClick={handleLogout}
            className="w-full flex items-center space-x-3 rounded-lg px-4 py-3 text-gray-700 hover:bg-gray-100 transition-all"
          >
            <FiLogOut className="text-lg" />
            <span>Logout</span>
          </button>
        </div>
      </div>

      {/* Toggle Button - Always positioned at top right */}
      <button
        onClick={toggleSidebar}
        className="absolute -right-4 top-4 z-10 bg-white border border-gray-200 shadow-md rounded-full p-2 cursor-pointer hover:bg-blue-50 transition-all"
      >
        {isOpen ? (
          <FiX className="text-blue-600 text-lg" />
        ) : (
          <FiMenu className="text-blue-600 text-lg" />
        )}
      </button>
    </aside>
  );
};

export default Sidebar;