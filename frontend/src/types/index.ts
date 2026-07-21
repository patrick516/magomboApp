export type PreacherStatus = "PENDING" | "APPROVED" | "REJECTED";

export interface Preacher {
  id: string;
  deviceId: string;
  name: string;
  position: string | null;
  status: PreacherStatus;
  createdAt: string;
  _count?: { sermons: number };
}

export interface Sermon {
  id: string;
  preacherId: string;
  theme: string;
  series: string | null;
  createdAt: string;
  preacher?: { id: string; name: string; position: string | null };
  preachings?: Preaching[];
}

export interface Preaching {
  id: string;
  sermonId: string;
  partNumber: number;
  dateRecorded: string;
  durationSeconds: number;
  audioUrl: string;
  playCount: number;
  createdAt: string;
}

export type DonationCategory =
  | "TITHE"
  | "OFFERING"
  | "BUILDING_FUND"
  | "MISSIONS"
  | "THANKSGIVING"
  | "OTHER";

export type DonationStatus = "PENDING" | "SUCCESS" | "FAILED";

export interface Donation {
  id: string;
  amount: number;
  category: DonationCategory;
  method: string;
  status: DonationStatus;
  reference: string | null;
  createdAt: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface AnalyticsOverview {
  preachers: { total: number; pending: number; approved: number };
  sermons: { total: number; totalParts: number; totalHours: number };
  engagement: { totalPlays: number };
  donations: {
    totalAmount: number;
    totalCount: number;
    byCategory: { category: DonationCategory; amount: number; count: number }[];
  };
}

export interface ActivityDay {
  date: string;
  sermons: number;
  preachings: number;
}

export interface RecentActivityItem {
  id: string;
  theme: string;
  preacherName: string;
  partNumber: number;
  createdAt: string;
}
