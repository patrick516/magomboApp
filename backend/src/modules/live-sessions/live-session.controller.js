const liveSessionService = require('./live-session.service');

async function startLiveSession(req, res, next) {
  try {
    const { preacherId, title } = req.body;
    if (!preacherId || !title) {
      return res.status(400).json({ success: false, message: 'preacherId and title are required' });
    }
    const session = await liveSessionService.startLiveSession({ preacherId, title });
    res.status(201).json({ success: true, data: session });
  } catch (err) { next(err); }
}

async function endLiveSession(req, res, next) {
  try {
    const session = await liveSessionService.endLiveSession(req.params.id);
    res.json({ success: true, data: session });
  } catch (err) { next(err); }
}

async function getCurrentLiveSession(req, res, next) {
  try {
    const session = await liveSessionService.getCurrentLiveSession();
    res.json({ success: true, data: session });
  } catch (err) { next(err); }
}

module.exports = { startLiveSession, endLiveSession, getCurrentLiveSession };
