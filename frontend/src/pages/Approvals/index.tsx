import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
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
  Trash2,
} from "lucide-react";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { format, parseISO } from "date-fns";
import {
  getAllPreachers,
  approvePreacher,
  rejectPreacher,
  deletePreacher,
} from "@/api/preachers";
import { getSermonsByPreacherAdmin, deleteSermon } from "@/api/sermons";
import type { PreacherStatus } from "@/types";

type FilterTab = "ALL" | PreacherStatus;

export default function Approvals() {
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState<FilterTab>("PENDING");
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);

  const {
    data: preachers = [],
    isLoading,
    error,
  } = useQuery({
    queryKey: ["preachers"],
    queryFn: getAllPreachers,
  });

  // Lazy-loaded sermon preview for whichever preacher card is expanded.
  // Cached per preacher, so re-expanding the same preacher later shows
  // instantly instead of refetching every time.
  const { data: previewSermons, isLoading: previewLoading } = useQuery({
    queryKey: ["preacherSermons", expandedId],
    queryFn: () => getSermonsByPreacherAdmin(expandedId as string),
    enabled: !!expandedId,
  });

  function togglePreview(preacherId: string) {
    setExpandedId((prev) => (prev === preacherId ? null : preacherId));
  }

  const approveMutation = useMutation({
    mutationFn: approvePreacher,
    onMutate: (id: string) => setActionLoadingId(id),
    onSettled: () => setActionLoadingId(null),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["preachers"] }),
  });

  const rejectMutation = useMutation({
    mutationFn: rejectPreacher,
    onMutate: (id: string) => setActionLoadingId(id),
    onSettled: () => setActionLoadingId(null),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["preachers"] }),
  });

  const deletePreacherMutation = useMutation({
    mutationFn: deletePreacher,
    onMutate: (id: string) => setActionLoadingId(id),
    onSettled: () => setActionLoadingId(null),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["preachers"] }),
  });

  const deleteSermonMutation = useMutation({
    mutationFn: ({ sermonId }: { preacherId: string; sermonId: string }) =>
      deleteSermon(sermonId),
    onSuccess: (_data, { preacherId }) => {
      queryClient.invalidateQueries({
        queryKey: ["preacherSermons", preacherId],
      });
      queryClient.invalidateQueries({ queryKey: ["preachers"] });
    },
  });

  const filtered =
    filter === "ALL" ? preachers : preachers.filter((p) => p.status === filter);
  const pendingCount = preachers.filter((p) => p.status === "PENDING").length;
  const showInitialSkeleton = isLoading && preachers.length === 0;

  return (
    <div>
      <Topbar title="Preacher Approvals" />
      <div className="p-8 space-y-6">
        {error && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            Could not load preachers. Is the backend running?
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

        {showInitialSkeleton ? (
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
              const isActionLoading = actionLoadingId === preacher.id;

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
                              disabled={isActionLoading}
                              onClick={() => rejectMutation.mutate(preacher.id)}
                            >
                              <X size={16} className="mr-1" /> Reject
                            </Button>
                            <Button
                              size="sm"
                              className="bg-success hover:bg-success/90 text-white"
                              disabled={isActionLoading}
                              onClick={() =>
                                approveMutation.mutate(preacher.id)
                              }
                            >
                              <Check size={16} className="mr-1" /> Approve
                            </Button>
                          </>
                        )}

                        <AlertDialog>
                          <AlertDialogTrigger asChild>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="text-destructive hover:bg-destructive/10"
                              disabled={isActionLoading}
                            >
                              <Trash2 size={16} />
                            </Button>
                          </AlertDialogTrigger>
                          <AlertDialogContent>
                            <AlertDialogHeader>
                              <AlertDialogTitle>
                                Delete {preacher.name}?
                              </AlertDialogTitle>
                              <AlertDialogDescription>
                                This permanently deletes this preacher and all{" "}
                                {preacher._count?.sermons ?? 0} of their
                                sermon(s), including all recorded parts. This
                                cannot be undone.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Cancel</AlertDialogCancel>
                              <AlertDialogAction
                                className="bg-destructive hover:bg-destructive/90"
                                onClick={() =>
                                  deletePreacherMutation.mutate(preacher.id)
                                }
                              >
                                Delete Permanently
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      </div>
                    </div>

                    {isExpanded && (
                      <div className="mt-4 pt-4 border-t space-y-3">
                        {previewLoading && !previewSermons ? (
                          <Skeleton className="h-16 w-full" />
                        ) : !previewSermons || previewSermons.length === 0 ? (
                          <p className="text-sm text-muted-foreground">
                            No sermons recorded by this preacher yet.
                          </p>
                        ) : (
                          previewSermons.map((sermon) => (
                            <div
                              key={sermon.id}
                              className="bg-muted/40 rounded-lg p-3"
                            >
                              <div className="flex items-center justify-between mb-2">
                                <p className="text-sm font-medium">
                                  {sermon.theme}
                                </p>
                                <AlertDialog>
                                  <AlertDialogTrigger asChild>
                                    <Button
                                      size="icon"
                                      variant="ghost"
                                      className="h-6 w-6 text-destructive"
                                    >
                                      <Trash2 size={14} />
                                    </Button>
                                  </AlertDialogTrigger>
                                  <AlertDialogContent>
                                    <AlertDialogHeader>
                                      <AlertDialogTitle>
                                        Delete "{sermon.theme}"?
                                      </AlertDialogTitle>
                                      <AlertDialogDescription>
                                        This permanently deletes this sermon and
                                        all its recorded parts. This cannot be
                                        undone.
                                      </AlertDialogDescription>
                                    </AlertDialogHeader>
                                    <AlertDialogFooter>
                                      <AlertDialogCancel>
                                        Cancel
                                      </AlertDialogCancel>
                                      <AlertDialogAction
                                        className="bg-destructive hover:bg-destructive/90"
                                        onClick={() =>
                                          deleteSermonMutation.mutate({
                                            preacherId: preacher.id,
                                            sermonId: sermon.id,
                                          })
                                        }
                                      >
                                        Delete Permanently
                                      </AlertDialogAction>
                                    </AlertDialogFooter>
                                  </AlertDialogContent>
                                </AlertDialog>
                              </div>
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
