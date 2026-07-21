import { NavLink } from "react-router-dom";
import { LayoutDashboard, UserCheck, Music, HandCoins } from "lucide-react";
import { cn } from "@/lib/utils";

const navItems = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard },
  { to: "/approvals", label: "Preacher Approvals", icon: UserCheck },
  { to: "/sermons", label: "Sermons", icon: Music },
  { to: "/donations", label: "Donations", icon: HandCoins },
];

export function Sidebar() {
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
    </aside>
  );
}
