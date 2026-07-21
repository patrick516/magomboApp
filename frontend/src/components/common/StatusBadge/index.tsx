import { Badge } from "@/components/ui/badge";
import type { PreacherStatus } from "@/types";

const statusStyles: Record<PreacherStatus, string> = {
  PENDING: "bg-accent/15 text-accent border-accent/30",
  APPROVED: "bg-success/15 text-success border-success/30",
  REJECTED: "bg-destructive/15 text-destructive border-destructive/30",
};

export function StatusBadge({ status }: { status: PreacherStatus }) {
  return (
    <Badge variant="outline" className={statusStyles[status]}>
      {status}
    </Badge>
  );
}
