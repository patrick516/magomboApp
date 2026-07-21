import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import "./index.css";
import { AppLayout } from "./components/Layout/AppLayout";
import Dashboard from "./pages/Dashboard";
import Approvals from "./pages/Approvals";
import Sermons from "./pages/Sermons";
import Donations from "./pages/Donations";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <BrowserRouter>
      <Routes>
        <Route element={<AppLayout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/approvals" element={<Approvals />} />
          <Route path="/sermons" element={<Sermons />} />
          <Route path="/donations" element={<Donations />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </StrictMode>,
);
