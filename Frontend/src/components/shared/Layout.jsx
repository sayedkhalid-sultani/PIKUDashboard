// src/components/shared/Layout.jsx
import React, { useState } from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";

export default function Layout() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  const toggleSidebar = () => {
    setIsSidebarOpen((prev) => !prev);
  };

  return (
    <div className="flex h-screen">
      {/* Sidebar with toggle */}
      <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
      <main
        className={`flex-1 overflow-auto transition-all duration-300 `}
      >
        <Outlet />
      </main>
    </div>
  );
}
