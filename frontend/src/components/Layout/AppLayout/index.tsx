import { Outlet } from "react-router-dom";
import { Sidebar } from "../Sidebar";

export function AppLayout() {
  return (
    <div className="min-h-screen bg-background">
      <Sidebar />
      <div className="ml-64">
        <Outlet />
      </div>
    </div>
  );
}
