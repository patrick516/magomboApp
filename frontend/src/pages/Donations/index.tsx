// src/pages/Donations/index.tsx

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Topbar } from "@/components/Layout/Topbar";
import { Card, CardContent } from "@/components/ui/card";
import { StatsCard } from "@/components/common/StatsCard/index";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  HandCoins,
  TrendingUp,
  Hash,
  MoreVertical,
  Check,
  X,
} from "lucide-react";
import { format, parseISO } from "date-fns";
import { getDonations, updateDonationStatus } from "@/api/donations";
import type { Donation, DonationStatus } from "@/types";

const statusStyles: Record<DonationStatus, string> = {
  PENDING: "bg-accent/15 text-accent border-accent/30",
  SUCCESS: "bg-success/15 text-success border-success/30",
  FAILED: "bg-destructive/15 text-destructive border-destructive/30",
};

const categoryLabels: Record<string, string> = {
  TITHE: "Tithe",
  OFFERING: "Offering",
  BUILDING_FUND: "Building Fund",
  MISSIONS: "Missions",
  THANKSGIVING: "Thanksgiving",
  OTHER: "Other",
};

function donorLabel(d: Donation): string {
  if (d.isAnonymous) return "Anonymous";
  const name = [d.donorFirstName, d.donorLastName].filter(Boolean).join(" ");
  return name || "—";
}

export default function Donations() {
  const queryClient = useQueryClient();

  const {
    data: donations = [],
    isLoading,
    // isFetching,
    error,
  } = useQuery({
    queryKey: ["donations"],
    queryFn: getDonations,
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: DonationStatus }) =>
      updateDonationStatus(id, status),
    onSuccess: (updated) => {
      queryClient.setQueryData<Donation[]>(["donations"], (prev) =>
        prev ? prev.map((d) => (d.id === updated.id ? updated : d)) : prev,
      );
    },
  });

  const successfulDonations = donations.filter((d) => d.status === "SUCCESS");
  const totalAmount = successfulDonations.reduce(
    (sum, d) => sum + Number(d.amount),
    0,
  );

  // Only show the full-page skeleton on the very first load (no cached data yet).
  // On every subsequent visit, cached data renders instantly while isFetching
  // quietly refreshes it in the background.
  const showInitialSkeleton = isLoading && donations.length === 0;

  return (
    <div>
      <Topbar title="Donations" />
      <div className="p-8 space-y-6">
        {error && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            Could not load donations. Is the backend running?
          </div>
        )}
        {statusMutation.isError && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            Could not update donation status. Please try again.
          </div>
        )}

        {showInitialSkeleton ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-28 rounded-xl" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <StatsCard
              label="Total Received"
              value={`MWK ${totalAmount.toLocaleString()}`}
              icon={HandCoins}
              accentColor="text-accent"
            />
            <StatsCard
              label="Successful Donations"
              value={successfulDonations.length}
              icon={TrendingUp}
              accentColor="text-success"
            />
            <StatsCard
              label="Total Records"
              value={donations.length}
              icon={Hash}
              accentColor="text-primary"
            />
          </div>
        )}

        <Card>
          <CardContent className="p-0">
            {showInitialSkeleton ? (
              <div className="p-6 space-y-3">
                {Array.from({ length: 4 }).map((_, i) => (
                  <Skeleton key={i} className="h-10 w-full" />
                ))}
              </div>
            ) : donations.length === 0 ? (
              <p className="p-10 text-center text-muted-foreground">
                No donations recorded yet.
              </p>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Date</TableHead>
                    <TableHead>Donor</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Reference</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead className="w-10"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {donations.map((d) => (
                    <TableRow key={d.id}>
                      <TableCell className="text-muted-foreground">
                        {format(parseISO(d.createdAt), "PP")}
                      </TableCell>
                      <TableCell>
                        <div>{donorLabel(d)}</div>
                        {!d.isAnonymous && d.donorPosition && (
                          <div className="text-xs text-muted-foreground">
                            {d.donorPosition}
                            {d.donorLocation ? ` · ${d.donorLocation}` : ""}
                          </div>
                        )}
                      </TableCell>
                      <TableCell>
                        {categoryLabels[d.category] || d.category}
                      </TableCell>
                      <TableCell>{d.method}</TableCell>
                      <TableCell className="text-muted-foreground">
                        {d.reference || "—"}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="outline"
                          className={statusStyles[d.status]}
                        >
                          {d.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right font-medium">
                        MWK {Number(d.amount).toLocaleString()}
                      </TableCell>
                      <TableCell>
                        {d.status === "PENDING" && (
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button
                                variant="ghost"
                                size="icon"
                                disabled={
                                  statusMutation.isPending &&
                                  statusMutation.variables?.id === d.id
                                }
                              >
                                <MoreVertical size={16} />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem
                                onClick={() =>
                                  statusMutation.mutate({
                                    id: d.id,
                                    status: "SUCCESS",
                                  })
                                }
                                className="text-success"
                              >
                                <Check size={14} className="mr-2" />
                                Mark as Received
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() =>
                                  statusMutation.mutate({
                                    id: d.id,
                                    status: "FAILED",
                                  })
                                }
                                className="text-destructive"
                              >
                                <X size={14} className="mr-2" />
                                Mark as Failed
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
