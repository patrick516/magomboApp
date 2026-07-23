// src/api/auth.ts

import { apiClient } from "./client";
import type { ApiResponse, LoginResponse } from "../types";

export async function login(email: string, password: string) {
  const res = await apiClient.post<ApiResponse<LoginResponse>>("/auth/login", {
    email,
    password,
  });
  return res.data.data;
}
