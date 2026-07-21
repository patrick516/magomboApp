import axios from "axios";
import { API_BASE_URL, ADMIN_API_KEY } from "../config/api";

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

export const adminApiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
    "x-admin-key": ADMIN_API_KEY,
  },
});
