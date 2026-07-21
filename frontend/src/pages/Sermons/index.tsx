import { useEffect, useState } from "react";
import { Topbar } from "@/components/Layout/Topbar";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { AudioPlayer } from "@/components/common/AudioPlayer/index";
import { StatusBadge } from "@/components/common/StatusBadge/index";
import { Music2, Calendar } from "lucide-react";
import { format, parseISO } from "date-fns";
import { getAllSermonsAdmin } from "@/api/sermons";
import type { Sermon } from "@/types";

function formatDuration(seconds: number) {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s.toString().padStart(2, "0")}`;
}

export default function Sermons() {
  const [sermons, setSermons] = useState<Sermon[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      try {
        const data = await getAllSermonsAdmin();
        setSermons(data);
      } catch {
        setError("Could not load sermons. Is the backend running?");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  return (
    <div>
      <Topbar title="Sermons" />
      <div className="p-8 space-y-4">
        {error && (
          <div className="bg-destructive/10 text-destructive px-4 py-3 rounded-lg text-sm">
            {error}
          </div>
        )}

        {loading ? (
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-32 w-full rounded-xl" />
            ))}
          </div>
        ) : sermons.length === 0 ? (
          <Card>
            <CardContent className="p-10 text-center text-muted-foreground">
              No sermons recorded yet.
            </CardContent>
          </Card>
        ) : (
          sermons.map((sermon) => (
            <Card key={sermon.id}>
              <CardContent className="p-5">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <Music2 size={16} className="text-primary" />
                      <h3 className="font-semibold">{sermon.theme}</h3>
                      {sermon.series && (
                        <Badge variant="outline" className="text-xs">
                          {sermon.series}
                        </Badge>
                      )}
                    </div>
                    <div className="flex items-center gap-2 mt-1 text-sm text-muted-foreground">
                      <span>{sermon.preacher?.name}</span>
                      {sermon.preacher?.status && (
                        <StatusBadge status={sermon.preacher.status} />
                      )}
                      <span className="flex items-center gap-1">
                        <Calendar size={12} />{" "}
                        {format(parseISO(sermon.createdAt), "PPP")}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="space-y-2 mt-4">
                  {sermon.preachings?.map((p) => (
                    <div
                      key={p.id}
                      className="flex items-center justify-between bg-muted/40 rounded-lg px-4 py-2"
                    >
                      <div className="flex items-center gap-3">
                        <Badge variant="outline">Part {p.partNumber}</Badge>
                        <span className="text-sm text-muted-foreground">
                          {formatDuration(p.durationSeconds)}
                        </span>
                        <span className="text-xs text-muted-foreground">
                          {p.playCount} play{p.playCount === 1 ? "" : "s"}
                        </span>
                      </div>
                      <AudioPlayer preachingId={p.id} />
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
