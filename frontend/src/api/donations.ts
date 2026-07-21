import { apiClient } from "./client";
import type { ApiResponse, Donation } from "../types";

export async function getDonations() {
  const res = await apiClient.get<ApiResponse<Donation[]>>("/donations");
  return res.data.data;
}
