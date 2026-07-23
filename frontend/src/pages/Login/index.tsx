// src/pages/Login/index.tsx

import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/context/AuthContext";
import churchLogo from "@/assets/logo/church-logo.jpeg";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await login(email, password);
      navigate("/", { replace: true });
    } catch {
      setError("Invalid email or password.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-muted/40 px-4">
      <div className="w-full max-w-sm rounded-xl overflow-hidden shadow-lg border border-border bg-card">
        {/* Navy header band — mirrors the sidebar's identity */}
        <div className="relative bg-primary px-8 pt-10 pb-8 flex flex-col items-center text-center">
          <div className="relative mb-4">
            {/* Signature: soft gold glow behind the logo */}
            <div
              className="absolute inset-0 rounded-full blur-xl opacity-40 scale-110"
              style={{ backgroundColor: "hsl(var(--accent))" }}
              aria-hidden="true"
            />
            <img
              src={churchLogo}
              alt="Magombo Assemblies of God logo"
              className="relative w-20 h-20 rounded-full object-cover ring-2 ring-accent"
            />
          </div>
          <h1 className="font-serif text-xl font-bold text-primary-foreground tracking-wide">
            Magombo Assemblies of God
          </h1>
          <p className="text-xs text-accent tracking-[0.2em] uppercase mt-1">
            New Jerusalem Temple
          </p>
        </div>

        {/* Form */}
        <div className="px-8 py-8">
          <p className="text-sm text-muted-foreground mb-6 text-center">
            Sign in to manage sermons and giving
          </p>
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <div className="bg-destructive/10 text-destructive px-3 py-2 rounded-md text-sm">
                {error}
              </div>
            )}
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoFocus
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <Button
              type="submit"
              disabled={submitting}
              className="w-full bg-accent text-accent-foreground hover:bg-accent/90"
            >
              {submitting ? "Signing in..." : "Sign In"}
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
