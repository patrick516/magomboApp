// src/components/Layout/Sidebar/index.tsx

import { NavLink, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  UserCheck,
  Music,
  HandCoins,
  LogOut,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/context/AuthContext";

const navItems = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard },
  { to: "/approvals", label: "Preacher Approvals", icon: UserCheck },
  { to: "/sermons", label: "Sermons", icon: Music },
  { to: "/donations", label: "Donations", icon: HandCoins },
];

export function Sidebar() {
  const { admin, logout } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  return (
    <aside className="w-64 h-screen bg-primary text-primary-foreground flex flex-col fixed left-0 top-0">
      <div className="p-6 border-b border-white/10">
        <h1 className="text-lg font-bold tracking-wide">MAGOMBO</h1>
        <p className="text-xs text-accent-light opacity-80 tracking-wider">
          NEW JERUSALEM TEMPLE
        </p>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map(({ to, label, icon: Icon }) => (
          <NavLink
            key={to}
            to={to}
            end={to === "/"}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors",
                isActive
                  ? "bg-accent text-white"
                  : "text-white/80 hover:bg-white/10 hover:text-white",
              )
            }
          >
            <Icon size={18} />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="p-4 border-t border-white/10">
        {admin && (
          <div className="px-4 pb-3">
            <p className="text-sm font-medium truncate">{admin.name}</p>
            <p className="text-xs text-white/60 truncate">{admin.email}</p>
          </div>
        )}
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium w-full text-white/80 hover:bg-white/10 hover:text-white transition-colors"
        >
          <LogOut size={18} />
          Logout
        </button>
      </div>
    </aside>
  );
}
