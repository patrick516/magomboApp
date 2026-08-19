require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const prisma = require("./src/lib/prisma");

const preacherRoutes = require("./src/modules/preachers/preacher.routes");
const sermonRoutes = require("./src/modules/sermons/sermon.routes");
const preachingRoutes = require("./src/modules/preachings/preaching.routes");
const donationRoutes = require("./src/modules/donations/donation.routes");
const analyticsRoutes = require("./src/modules/analytics/analytics.routes");
const authRoutes = require("./src/modules/auth/auth.routes");
const liveSessionRoutes = require("./src/modules/live-sessions/live-session.routes");
const announcementRoutes = require("./src/modules/announcements/announcement.routes");
const prayerRequestRoutes = require("./src/modules/prayer-requests/prayer-request.routes");
const testimonyRoutes = require("./src/modules/testimonies/testimony.routes");
const smallGroupRoutes = require("./src/modules/small-groups/small-group.routes");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(helmet());
app.use(
  cors({
    origin: [
      "http://localhost:5173",
      "http://localhost:3000",
      "http://localhost:3001",
      "https://magombo-app.vercel.app",
      ...(process.env.CORS_ORIGIN ? [process.env.CORS_ORIGIN] : []),
    ],
    credentials: true,
  }),
);
app.use(morgan("dev"));
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

app.use("/uploads", express.static("uploads"));

app.use("/api/preachers", preacherRoutes);
app.use("/api/sermons", sermonRoutes);
app.use("/api/preachings", preachingRoutes);
app.use("/api/donations", donationRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/live-sessions", liveSessionRoutes);
app.use("/api/announcements", announcementRoutes);
app.use("/api/prayer-requests", prayerRequestRoutes);
app.use("/api/testimonies", testimonyRoutes);
app.use("/api/small-groups", smallGroupRoutes);

app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
  });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
});

app.use((err, req, res, next) => {
  console.error("Server error:", err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Internal server error",
  });
});

const gracefulShutdown = () => {
  console.log("\nShutting down...");
  prisma
    .$disconnect()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
};
process.on("SIGTERM", gracefulShutdown);
process.on("SIGINT", gracefulShutdown);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
