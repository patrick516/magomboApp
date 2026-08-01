import { useQuery } from "@tanstack/react-query";
import { Topbar } from "@/components/Layout/Topbar";
import { StatsCard } from "@/components/common/StatsCard/index";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Users, Music2, PlayCircle, HandCoins, Clock } from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import {
  getOverview,
  getActivityOverTime,
  getRecentActivity,
} from "@/api/analytics";
import { format, parseISO } from "date-fns";

export default function Dashboard() {
  const { data: overview, isLoading: overviewLoading } = useQuery({
    queryKey: ["analytics", "overview"],
    queryFn: getOverview,
  });

  const { data: activity = [], isLoading: activityLoading } = useQuery({
    queryKey: ["analytics", "activity", 30],
    queryFn: () => getActivityOverTime(30),
  });

  const { data: recent = [], isLoading: recentLoading } = useQuery({
    queryKey: ["analytics", "recent", 8],
    queryFn: () => getRecentActivity(8),
  });

  // const isAnyError = false; // individual query.error can be checked per-section if desired

  // Only show skeletons before we have any cached data at all; on revisits,
  // cached values render instantly while these queries refresh in the background.
  const showOverviewSkeleton = overviewLoading && !overview;
  const showActivitySkeleton = activityLoading && activity.length === 0;
  const showRecentSkeleton = recentLoading && recent.length === 0;

  return (
    <div>
      <Topbar title="Dashboard" />
      <div className="p-8 space-y-6">
        {showOverviewSkeleton ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <Skeleton key={i} className="h-28 rounded-xl" />
            ))}
          </div>
        ) : overview ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
            <StatsCard
              label="Approved Preachers"
              value={overview.preachers.approved}
              icon={Users}
              accentColor="text-primary"
            />
            <StatsCard
              label="Pending Approvals"
              value={overview.preachers.pending}
              icon={Users}
              accentColor="text-accent"
            />
            <StatsCard
              label="Total Sermons"
              value={overview.sermons.total}
              icon={Music2}
              accentColor="text-primary"
            />
            <StatsCard
              label="Total Plays"
              value={overview.engagement.totalPlays}
              icon={PlayCircle}
              accentColor="text-success"
            />
            <StatsCard
              label="Donations Received"
              value={`MWK ${overview.donations.totalAmount.toLocaleString()}`}
              icon={HandCoins}
              accentColor="text-accent"
            />
          </div>
        ) : null}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle className="text-base">
                Activity — Last 30 Days
              </CardTitle>
            </CardHeader>
            <CardContent>
              {showActivitySkeleton ? (
                <Skeleton className="h-64 w-full" />
              ) : (
                <ResponsiveContainer width="100%" height={260}>
                  <AreaChart data={activity}>
                    <defs>
                      <linearGradient
                        id="sermonsGrad"
                        x1="0"
                        y1="0"
                        x2="0"
                        y2="1"
                      >
                        <stop
                          offset="5%"
                          stopColor="#1B2A4A"
                          stopOpacity={0.4}
                        />
                        <stop
                          offset="95%"
                          stopColor="#1B2A4A"
                          stopOpacity={0}
                        />
                      </linearGradient>
                      <linearGradient
                        id="preachingsGrad"
                        x1="0"
                        y1="0"
                        x2="0"
                        y2="1"
                      >
                        <stop
                          offset="5%"
                          stopColor="#C9A24B"
                          stopOpacity={0.5}
                        />
                        <stop
                          offset="95%"
                          stopColor="#C9A24B"
                          stopOpacity={0}
                        />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                    <XAxis
                      dataKey="date"
                      tickFormatter={(d) => format(parseISO(d), "MMM d")}
                      fontSize={12}
                    />
                    <YAxis allowDecimals={false} fontSize={12} />
                    <Tooltip
                      labelFormatter={(d) =>
                        format(parseISO(d as string), "PPP")
                      }
                    />
                    <Area
                      type="monotone"
                      dataKey="sermons"
                      name="New Themes"
                      stroke="#1B2A4A"
                      fill="url(#sermonsGrad)"
                      strokeWidth={2}
                    />
                    <Area
                      type="monotone"
                      dataKey="preachings"
                      name="Recordings"
                      stroke="#C9A24B"
                      fill="url(#preachingsGrad)"
                      strokeWidth={2}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Clock size={16} /> Recent Recordings
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {showRecentSkeleton ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <Skeleton key={i} className="h-12 w-full" />
                ))
              ) : recent.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  No recordings yet.
                </p>
              ) : (
                recent.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between border-b pb-2 last:border-0"
                  >
                    <div>
                      <p className="text-sm font-medium">{item.theme}</p>
                      <p className="text-xs text-muted-foreground">
                        {item.preacherName}
                      </p>
                    </div>
                    <Badge variant="outline">Part {item.partNumber}</Badge>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
