// src/api/client.ts

import axios from "axios";
import { API_BASE_URL } from "../config/api";
import { getToken, clearToken } from "../lib/auth";

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Attach the admin's JWT (if present) to every request. Public endpoints
// (e.g. GET /sermons) simply ignore the header; protected endpoints
// (donations list, analytics, preacher approvals) require it.
apiClient.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// If the token is invalid/expired, clear it and send the admin back to login
// rather than leaving them staring at a silently-failing dashboard.
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearToken();
      if (window.location.pathname !== "/login") {
        window.location.href = "/login";
      }
    }
    return Promise.reject(error);
  },
);
