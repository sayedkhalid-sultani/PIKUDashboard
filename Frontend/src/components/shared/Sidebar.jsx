import { NavLink, useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useAuthStore } from "../../store/Shared/Store";
import { FiMap, FiUser, FiPieChart, FiSettings, FiLock, FiLogOut, FiGlobe, FiChevronLeft, FiChevronRight } from "react-icons/fi";
import { MdAddChart } from "react-icons/md";

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

  // Link classes for expanded state
  const linkClasses = ({ isActive }) =>
    `flex items-center space-x-3 rounded-lg px-4 py-3 transition-all ${isActive
      ? "bg-blue-100 text-blue-700 font-semibold"
      : "text-gray-700 hover:bg-gray-100"
    }`;

  // Link classes for collapsed state (icon only)
  const collapsedLinkClasses = ({ isActive }) =>
    `flex items-center justify-center rounded-lg p-3 transition-all ${isActive
      ? "bg-blue-100 text-blue-700"
      : "text-gray-700 hover:bg-gray-100"
    }`;

  return (
    <div className="flex">
      <aside
        className={`relative h-screen bg-white border-r border-gray-200 transition-all duration-300 ${isOpen ? "w-64" : "w-20"
          }`}
      >
        <div className="h-full flex flex-col p-5">
          {/* Logo and Toggle Button */}
          <div className={`flex items-center ${isOpen ? "justify-between" : "justify-center"} mb-8`}>
            <div className={`flex items-center ${isOpen ? "space-x-2" : ""}`}>
              <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
                <FiGlobe className="text-white text-lg" />
              </div>
              {isOpen && (
                <h1 className="text-xl font-bold text-gray-800">PIKU Dashboard</h1>
              )}
            </div>

            {/* Toggle Button Inside Header */}
            {isOpen && (
              <button
                onClick={toggleSidebar}
                className="bg-blue-600 text-white shadow-lg rounded-full p-2 cursor-pointer hover:bg-blue-700 transition-all flex items-center justify-center "
                title="Collapse Sidebar"
              >
                <FiChevronLeft className="text-lg" />
              </button>
            )}
          </div>

          {/* Navigation */}
          <nav className="space-y-1 flex-1">
            {/* Dashboard children */}
            <NavLink
              to="/dashboard/CountryDashboard"
              className={isOpen ? linkClasses : collapsedLinkClasses}
              title="Country Map"
            >
              <FiMap className="text-lg" />
              {isOpen && <span>Country Map</span>}
            </NavLink>

            <NavLink
              to="/dashboard/CountryProfile"
              className={isOpen ? linkClasses : collapsedLinkClasses}
              title="Country Profile"
            >
              <FiUser className="text-lg" />
              {isOpen && <span>Country Profile</span>}
            </NavLink>

            <NavLink
              to="/dashboard/CountryProfilemui"
              className={isOpen ? linkClasses : collapsedLinkClasses}
              title="Country Profile MUI"
            >
              <FiUser className="text-lg" />
              {isOpen && <span>Country Profile MUI</span>}
            </NavLink>


            <NavLink
              to="/dashboard/AddChart"
              className={isOpen ? linkClasses : collapsedLinkClasses}
              title="Add Indicator"
            >
              <MdAddChart className="text-lg" />
              {isOpen && <span>Add Chart</span>}
            </NavLink>

            {/* Change Password */}
            <NavLink
              to="/change-password"
              className={isOpen ? linkClasses : collapsedLinkClasses}
              title="Change Password"
            >
              <FiLock className="text-lg" />
              {isOpen && <span>Change Password</span>}
            </NavLink>
          </nav>

          {/* Admin area */}
          {isAdmin && (
            <div className="pt-5 border-t border-gray-200">
              {isOpen && (
                <h3 className="text-xs font-semibold uppercase text-gray-500 px-4 mb-3">Admin</h3>
              )}
              <div className="space-y-1">
                <NavLink
                  to="/admin/indicators"
                  className={isOpen ? linkClasses : collapsedLinkClasses}
                  title="Indicators"
                >
                  <FiSettings className="text-lg" />
                  {isOpen && <span>Indicators</span>}
                </NavLink>
                <NavLink
                  to="/admin/users"
                  className={isOpen ? linkClasses : collapsedLinkClasses}
                  title="Users"
                >
                  <FiUser className="text-lg" />
                  {isOpen && <span>Users</span>}
                </NavLink>
              </div>
            </div>
          )}

          {/* Logout Button */}
          <div className="mt-5">
            <button
              onClick={handleLogout}
              className={`${isOpen ? "w-full flex items-center space-x-3 rounded-lg px-4 py-3" : "w-full flex items-center justify-center rounded-lg p-3"} text-gray-700 hover:bg-gray-100 transition-all`}
              title="Logout"
            >
              <FiLogOut className="text-lg" />
              {isOpen && <span>Logout</span>}
            </button>
          </div>
        </div>

        {/* External Toggle Button - Only shown when sidebar is collapsed */}
        {!isOpen && (
          <button
            onClick={toggleSidebar}
            className="absolute -right-3 top-5 z-2000 bg-blue-600 text-white shadow-lg rounded-full p-2 cursor-pointer hover:bg-blue-700 transition-all flex items-center justify-center"
            title="Expand Sidebar"
          >
            <FiChevronRight className="text-lg" />
          </button>
        )}
      </aside>
    </div>
  );
};

export default Sidebar;