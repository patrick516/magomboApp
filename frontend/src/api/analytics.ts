import { adminApiClient } from "./client";
import type {
  ApiResponse,
  AnalyticsOverview,
  ActivityDay,
  RecentActivityItem,
} from "../types";

export async function getOverview() {
  const res = await adminApiClient.get<ApiResponse<AnalyticsOverview>>(
    "/analytics/overview",
  );
  return res.data.data;
}

export async function getActivityOverTime(days = 30) {
  const res = await adminApiClient.get<ApiResponse<ActivityDay[]>>(
    "/analytics/activity",
    {
      params: { days },
    },
  );
  return res.data.data;
}

export async function getRecentActivity(limit = 10) {
  const res = await adminApiClient.get<ApiResponse<RecentActivityItem[]>>(
    "/analytics/recent",
    {
      params: { limit },
    },
  );
  return res.data.data;
}
