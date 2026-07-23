import { apiClient } from "./client";
import type { ApiResponse, Donation, DonationStatus } from "../types";

export async function getDonations() {
  const res = await apiClient.get<ApiResponse<Donation[]>>("/donations");
  return res.data.data;
}

export async function updateDonationStatus(id: string, status: DonationStatus) {
  const res = await apiClient.patch<ApiResponse<Donation>>(
    `/donations/${id}/status`,
    { status },
  );
  return res.data.data;
}
