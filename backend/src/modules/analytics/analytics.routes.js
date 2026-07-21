const express = require("express");
const router = express.Router();
const analyticsController = require("./analytics.controller");
const adminAuth = require("../../middleware/adminAuth");

router.get("/overview", adminAuth, analyticsController.getOverview);
router.get("/activity", adminAuth, analyticsController.getActivityOverTime);
router.get("/recent", adminAuth, analyticsController.getRecentActivity);

module.exports = router;
