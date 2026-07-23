const express = require("express");
const router = express.Router();
const analyticsController = require("./analytics.controller");
const { authenticateAdmin } = require("../../middleware/auth");

router.get("/overview", authenticateAdmin, analyticsController.getOverview);
router.get(
  "/activity",
  authenticateAdmin,
  analyticsController.getActivityOverTime,
);
router.get("/recent", authenticateAdmin, analyticsController.getRecentActivity);

module.exports = router;
