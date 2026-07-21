import { Card, CardContent } from "@/components/ui/card";
import type { LucideIcon } from "lucide-react";

interface StatsCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  accentColor?: string;
}

export function StatsCard({
  label,
  value,
  icon: Icon,
  accentColor = "text-primary",
}: StatsCardProps) {
  return (
    <Card>
      <CardContent className="p-6 flex items-center justify-between">
        <div>
          <p className="text-sm text-muted-foreground">{label}</p>
          <p className="text-3xl font-bold mt-1">{value}</p>
        </div>
        <div className={`p-3 rounded-full bg-muted ${accentColor}`}>
          <Icon size={24} />
        </div>
      </CardContent>
    </Card>
  );
}
