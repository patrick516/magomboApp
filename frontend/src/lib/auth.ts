// src/lib/auth.ts

const TOKEN_KEY = "magombo_admin_token";
const ADMIN_KEY = "magombo_admin_info";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string) {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(ADMIN_KEY);
}

export function getStoredAdmin<T>(): T | null {
  const raw = localStorage.getItem(ADMIN_KEY);
  return raw ? (JSON.parse(raw) as T) : null;
}

export function setStoredAdmin(admin: unknown) {
  localStorage.setItem(ADMIN_KEY, JSON.stringify(admin));
}
