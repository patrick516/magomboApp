const testimonyService = require('./testimony.service');

async function createTestimony(req, res, next) {
  try {
    const { authorName, isAnonymous, message, deviceId } = req.body;
    if (!message) {
      return res.status(400).json({ success: false, message: 'message is required' });
    }
    const testimony = await testimonyService.createTestimony({ authorName, isAnonymous, message, deviceId });
    res.status(201).json({ success: true, data: testimony });
  } catch (err) { next(err); }
}

async function listApprovedTestimonies(req, res, next) {
  try {
    const testimonies = await testimonyService.listApprovedTestimonies();
    res.json({ success: true, data: testimonies });
  } catch (err) { next(err); }
}

async function listAllTestimonies(req, res, next) {
  try {
    const testimonies = await testimonyService.listAllTestimonies();
    res.json({ success: true, data: testimonies });
  } catch (err) { next(err); }
}

async function updateStatus(req, res, next) {
  try {
    const { status } = req.body;
    if (!['PENDING', 'APPROVED', 'REJECTED'].includes(status)) {
      return res.status(400).json({ success: false, message: 'status must be PENDING, APPROVED, or REJECTED' });
    }
    const testimony = await testimonyService.updateStatus(req.params.id, status);
    res.json({ success: true, data: testimony });
  } catch (err) { next(err); }
}

module.exports = { createTestimony, listApprovedTestimonies, listAllTestimonies, updateStatus };
