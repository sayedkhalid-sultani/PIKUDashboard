import { NavLink, Outlet } from "react-router-dom";

export default function DashboardContent() {
  return (
    <div className="flex h-full flex-col min-h-0">
      {/* Optional subnav here */}
      <div className="flex-1 min-h-0 overflow-y-auto">
        <Outlet />
      </div>
    </div>
  );
}
