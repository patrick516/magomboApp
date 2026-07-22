import { apiClient, adminApiClient } from "./client";
import type { ApiResponse, Sermon } from "../types";

export async function getSermons(params?: {
  preacherId?: string;
  since?: string;
}) {
  const res = await apiClient.get<ApiResponse<Sermon[]>>("/sermons", {
    params,
  });
  return res.data.data;
}

export async function getAllSermonsAdmin() {
  const res =
    await adminApiClient.get<ApiResponse<Sermon[]>>("/sermons/admin/all");
  return res.data.data;
}

export async function getSermonsByPreacherAdmin(preacherId: string) {
  const all = await getAllSermonsAdmin();
  return all.filter((s) => s.preacherId === preacherId);
}

export async function deleteSermon(id: string) {
  await adminApiClient.delete(`/sermons/${id}`);
}
