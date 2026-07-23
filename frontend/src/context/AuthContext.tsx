// src/context/AuthContext.tsx

import { createContext, useContext, useState, type ReactNode } from "react";
import { login as loginApi } from "../api/auth";
import {
  getToken,
  setToken,
  clearToken,
  getStoredAdmin,
  setStoredAdmin,
} from "../lib/auth";
import type { Admin } from "../types";

interface AuthContextValue {
  admin: Admin | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [admin, setAdmin] = useState<Admin | null>(() =>
    getStoredAdmin<Admin>(),
  );
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(
    () => !!getToken(),
  );

  async function login(email: string, password: string) {
    const result = await loginApi(email, password);
    setToken(result.token);
    setStoredAdmin(result.admin);
    setAdmin(result.admin);
    setIsAuthenticated(true);
  }

  function logout() {
    clearToken();
    setAdmin(null);
    setIsAuthenticated(false);
  }

  return (
    <AuthContext.Provider value={{ admin, isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within an AuthProvider");
  return ctx;
}
