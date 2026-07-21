const analyticsService = require("./analytics.service");

async function getOverview(req, res, next) {
  try {
    const overview = await analyticsService.getOverview();
    res.json({ success: true, data: overview });
  } catch (err) {
    next(err);
  }
}

async function getActivityOverTime(req, res, next) {
  try {
    const days = req.query.days ? Number(req.query.days) : 30;
    const activity = await analyticsService.getActivityOverTime(days);
    res.json({ success: true, data: activity });
  } catch (err) {
    next(err);
  }
}

async function getRecentActivity(req, res, next) {
  try {
    const limit = req.query.limit ? Number(req.query.limit) : 10;
    const activity = await analyticsService.getRecentActivity(limit);
    res.json({ success: true, data: activity });
  } catch (err) {
    next(err);
  }
}

module.exports = { getOverview, getActivityOverTime, getRecentActivity };
