import { apiClient, adminApiClient } from "./client";
import type { ApiResponse, Preacher } from "../types";

export async function getApprovedPreachers() {
  const res = await apiClient.get<ApiResponse<Preacher[]>>("/preachers");
  return res.data.data;
}

export async function getAllPreachers() {
  const res = await adminApiClient.get<ApiResponse<Preacher[]>>(
    "/preachers/admin/all",
  );
  return res.data.data;
}

export async function getPendingPreachers() {
  const res = await adminApiClient.get<ApiResponse<Preacher[]>>(
    "/preachers/admin/pending",
  );
  return res.data.data;
}

export async function approvePreacher(id: string) {
  const res = await adminApiClient.post<ApiResponse<Preacher>>(
    `/preachers/${id}/approve`,
  );
  return res.data.data;
}

export async function rejectPreacher(id: string) {
  const res = await adminApiClient.post<ApiResponse<Preacher>>(
    `/preachers/${id}/reject`,
  );
  return res.data.data;
}

export async function deletePreacher(id: string) {
  await adminApiClient.delete(`/preachers/${id}`);
}
