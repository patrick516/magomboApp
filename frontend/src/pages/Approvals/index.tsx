import { useEffect, useState } from "react";
import { Topbar } from "@/components/Layout/Topbar";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { StatusBadge } from "@/components/common/StatusBadge/index";
import { AudioPlayer } from "@/components/common/AudioPlayer/index";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Check,
  X,
  Smartphone,
  Calendar,
  ChevronDown,
  ChevronUp,
  Music2,
} from "lucide-react";
import { format, parseISO } from "date-fns";
import {
  getAllPreachers,
  approvePreacher,
  rejectPreacher,
} from "@/api/preachers";
import { getSermonsByPreacherAdmin } from "@/api/sermons";
import type { Preacher, PreacherStatus, Sermon } from "@/types";

type FilterTab = "ALL" | PreacherStatus;

export default function Approvals() {
  const [preachers, setPreachers] = useState<Preacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<FilterTab>("PENDING");
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [previewSermons, setPreviewSermons] = useState<
    Record<string, Sermon[]>
  >({});
  const [previewLoading, setPreviewLoading] = useState<string | null>(null);

  async function load() {
    setLoading(true);
    try {
      const data = await getAllPreachers();
      setPreachers(data);
      setError(null);
    } catch {
      setError("Could not load preachers. Is the backend running?");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function togglePreview(preacherId: string) {
    if (expandedId === preacherId) {
      setExpandedId(null);
      return;
    }
    setExpandedId(preacherId);
    if (!previewSermons[preacherId]) {
      setPreviewLoading(preacherId);
      try {
        const sermons = await getSermonsByPreacherAdmin(preacherId);
        setPreviewSermons((prev) => ({ ...prev, [preacherId]: sermons }));
      } finally {
        setPreviewLoading(null);
      }
    }
  }

  async function handleApprove(id: string) {
    setActionLoading(id);
    try {
      await approvePreacher(id);
      await load();
    } finally {
      setActionLoading(null);
    }
  }

  async function handleReject(id: string) {
    setActionLoading(id);
    try {
      await rejectPreacher(id);
      await load();
    } finally {
      setActionLoading(null);
    }
  }

  const filtered =
    filter === "ALL" ? preachers : preachers.filter((p) => p.status === filter);
  const pendingCount = preachers.filter((p) => p.status === "PENDING").length;

  return (
    <div>
      <Topbar title="Preacher Approvals" />
      <div className="p-8 space-y-6">
        {error && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            {error}
          </div>
        )}

        <Tabs value={filter} onValueChange={(v) => setFilter(v as FilterTab)}>
          <TabsList>
            <TabsTrigger value="PENDING">
              Pending {pendingCount > 0 && `(${pendingCount})`}
            </TabsTrigger>
            <TabsTrigger value="APPROVED">Approved</TabsTrigger>
            <TabsTrigger value="REJECTED">Rejected</TabsTrigger>
            <TabsTrigger value="ALL">All</TabsTrigger>
          </TabsList>
        </Tabs>

        {loading ? (
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-24 w-full rounded-xl" />
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <Card>
            <CardContent className="p-10 text-center text-muted-foreground">
              No {filter !== "ALL" ? filter.toLowerCase() : ""} preachers to
              show.
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {filtered.map((preacher) => {
              const isExpanded = expandedId === preacher.id;
              const sermons = previewSermons[preacher.id];

              return (
                <Card key={preacher.id}>
                  <CardContent className="p-5">
                    <div className="flex items-center justify-between gap-4">
                      <div className="flex items-center gap-4 flex-1 min-w-0">
                        <Avatar className="h-12 w-12 bg-primary text-white">
                          <AvatarFallback className="bg-primary text-white">
                            {preacher.name.charAt(0).toUpperCase()}
                          </AvatarFallback>
                        </Avatar>
                        <div className="min-w-0">
                          <div className="flex items-center gap-2">
                            <p className="font-semibold truncate">
                              {preacher.name}
                            </p>
                            <StatusBadge status={preacher.status} />
                          </div>
                          <p className="text-sm text-muted-foreground truncate">
                            {preacher.position || "No position given"}
                          </p>
                          <div className="flex items-center gap-4 mt-1 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <Smartphone size={12} />{" "}
                              {preacher.deviceId.slice(0, 20)}...
                            </span>
                            <span className="flex items-center gap-1">
                              <Calendar size={12} />{" "}
                              {format(parseISO(preacher.createdAt), "PPP")}
                            </span>
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-2 shrink-0">
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => togglePreview(preacher.id)}
                        >
                          <Music2 size={16} className="mr-1" />
                          {preacher._count?.sermons ?? 0} sermon(s)
                          {isExpanded ? (
                            <ChevronUp size={16} className="ml-1" />
                          ) : (
                            <ChevronDown size={16} className="ml-1" />
                          )}
                        </Button>

                        {preacher.status === "PENDING" && (
                          <>
                            <Button
                              size="sm"
                              variant="outline"
                              className="border-destructive text-destructive hover:bg-destructive/10"
                              disabled={actionLoading === preacher.id}
                              onClick={() => handleReject(preacher.id)}
                            >
                              <X size={16} className="mr-1" /> Reject
                            </Button>
                            <Button
                              size="sm"
                              className="bg-success hover:bg-success/90 text-white"
                              disabled={actionLoading === preacher.id}
                              onClick={() => handleApprove(preacher.id)}
                            >
                              <Check size={16} className="mr-1" /> Approve
                            </Button>
                          </>
                        )}
                      </div>
                    </div>

                    {isExpanded && (
                      <div className="mt-4 pt-4 border-t space-y-3">
                        {previewLoading === preacher.id ? (
                          <Skeleton className="h-16 w-full" />
                        ) : !sermons || sermons.length === 0 ? (
                          <p className="text-sm text-muted-foreground">
                            No sermons recorded by this preacher yet.
                          </p>
                        ) : (
                          sermons.map((sermon) => (
                            <div
                              key={sermon.id}
                              className="bg-muted/40 rounded-lg p-3"
                            >
                              <p className="text-sm font-medium mb-2">
                                {sermon.theme}
                              </p>
                              <div className="space-y-2">
                                {sermon.preachings?.map((p) => (
                                  <div
                                    key={p.id}
                                    className="flex items-center justify-between bg-background rounded-md px-3 py-2"
                                  >
                                    <span className="text-xs text-muted-foreground">
                                      Part {p.partNumber}
                                    </span>
                                    <AudioPlayer preachingId={p.id} />
                                  </div>
                                ))}
                              </div>
                            </div>
                          ))
                        )}
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
