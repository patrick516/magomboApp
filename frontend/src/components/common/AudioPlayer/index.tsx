import { useRef, useState } from "react";
import { Play, Pause, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { API_BASE_URL } from "@/config/api";

interface AudioPlayerProps {
  preachingId: string;
}

export function AudioPlayer({ preachingId }: AudioPlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const audioUrl = `${API_BASE_URL}/preachings/${preachingId}/audio`;

  function togglePlay() {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
      setIsPlaying(false);
    } else {
      setIsLoading(true);
      audio.play().catch(() => setIsLoading(false));
    }
  }

  return (
    <div className="flex items-center gap-2">
      <Button
        size="icon"
        variant="outline"
        className="h-8 w-8 rounded-full"
        onClick={togglePlay}
        disabled={isLoading}
      >
        {isLoading ? (
          <Loader2 size={14} className="animate-spin" />
        ) : isPlaying ? (
          <Pause size={14} />
        ) : (
          <Play size={14} />
        )}
      </Button>
      <audio
        ref={audioRef}
        src={audioUrl}
        onCanPlay={() => setIsLoading(false)}
        onPlay={() => {
          setIsPlaying(true);
          setIsLoading(false);
        }}
        onPause={() => setIsPlaying(false)}
        onEnded={() => setIsPlaying(false)}
        preload="none"
      />
    </div>
  );
}
