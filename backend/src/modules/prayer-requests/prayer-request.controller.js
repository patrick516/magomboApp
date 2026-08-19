const prayerRequestService = require('./prayer-request.service');

async function createPrayerRequest(req, res, next) {
  try {
    const { requesterName, isAnonymous, message, deviceId } = req.body;
    if (!message) {
      return res.status(400).json({ success: false, message: 'message is required' });
    }
    const request = await prayerRequestService.createPrayerRequest({ requesterName, isAnonymous, message, deviceId });
    res.status(201).json({ success: true, data: request });
  } catch (err) { next(err); }
}

async function listPrayerRequests(req, res, next) {
  try {
    const requests = await prayerRequestService.listPrayerRequests();
    res.json({ success: true, data: requests });
  } catch (err) { next(err); }
}

async function markPrayedFor(req, res, next) {
  try {
    const request = await prayerRequestService.markPrayedFor(req.params.id);
    res.json({ success: true, data: request });
  } catch (err) { next(err); }
}

module.exports = { createPrayerRequest, listPrayerRequests, markPrayedFor };
