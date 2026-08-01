import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import "./index.css";
import { AppLayout } from "./components/Layout/AppLayout";
import { AuthProvider } from "./context/AuthContext";
import { ProtectedRoute } from "./components/ProtectedRoute";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Approvals from "./pages/Approvals";
import Sermons from "./pages/Sermons";
import Donations from "./pages/Donations";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Show cached data instantly on revisit, then quietly refetch in the
      // background instead of showing a loading skeleton every navigation.
      staleTime: 30 * 1000, // data considered "fresh" for 30s — no refetch within this window
      refetchOnWindowFocus: true, // silently refresh when the tab regains focus
      refetchOnMount: true, // refetch in background on remount, but cached data shows first
      retry: 1,
    },
  },
});

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AuthProvider>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route element={<ProtectedRoute />}>
              <Route element={<AppLayout />}>
                <Route path="/" element={<Dashboard />} />
                <Route path="/approvals" element={<Approvals />} />
                <Route path="/sermons" element={<Sermons />} />
                <Route path="/donations" element={<Donations />} />
              </Route>
            </Route>
          </Routes>
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  </StrictMode>,
);
