import { useRef, useState, useCallback } from "react";
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
  const [signedUrl, setSignedUrl] = useState<string>("");

  const fetchSignedUrl = useCallback(async () => {
    const response = await fetch(
      `${API_BASE_URL}/preachings/${preachingId}/audio`,
    );
    if (!response.ok) throw new Error("Failed to get audio URL");
    const data = await response.json();
    return data.data.signedUrl as string;
  }, [preachingId]);

  async function togglePlay() {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
      setIsPlaying(false);
      return;
    }

    setIsLoading(true);

    try {
      // If we don't have a signed URL yet, fetch it
      let url = signedUrl;
      if (!url) {
        url = await fetchSignedUrl();
        setSignedUrl(url);
      }

      // Always set src before playing (in case it was cleared)
      audio.src = url;
      await audio.play();
    } catch (err) {
      console.error("Playback error:", err);
      setIsLoading(false);
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
