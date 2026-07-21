import { useEffect, useState } from "react";
import { Topbar } from "@/components/Layout/Topbar";
import { Card, CardContent } from "@/components/ui/card";
import { StatsCard } from "@/components/common/StatsCard/index";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { HandCoins, TrendingUp, Hash } from "lucide-react";
import { format, parseISO } from "date-fns";
import { getDonations } from "@/api/donations";
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

export default function Donations() {
  const [donations, setDonations] = useState<Donation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      try {
        const data = await getDonations();
        setDonations(data);
      } catch {
        setError("Could not load donations. Is the backend running?");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const successfulDonations = donations.filter((d) => d.status === "SUCCESS");
  const totalAmount = successfulDonations.reduce(
    (sum, d) => sum + Number(d.amount),
    0,
  );

  return (
    <div>
      <Topbar title="Donations" />
      <div className="p-8 space-y-6">
        {error && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            {error}
          </div>
        )}

        {loading ? (
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
            {loading ? (
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
                    <TableHead>Category</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Reference</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {donations.map((d) => (
                    <TableRow key={d.id}>
                      <TableCell className="text-muted-foreground">
                        {format(parseISO(d.createdAt), "PP")}
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
