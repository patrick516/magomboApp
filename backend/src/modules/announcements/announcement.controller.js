const announcementService = require('./announcement.service');

async function listAnnouncements(req, res, next) {
  try {
    const announcements = await announcementService.listAnnouncements();
    res.json({ success: true, data: announcements });
  } catch (err) { next(err); }
}

async function createAnnouncement(req, res, next) {
  try {
    const { preacherId, title, body, eventDate } = req.body;
    if (!title || !body) {
      return res.status(400).json({ success: false, message: 'title and body are required' });
    }
    const announcement = await announcementService.createAnnouncement({ preacherId, title, body, eventDate });
    res.status(201).json({ success: true, data: announcement });
  } catch (err) { next(err); }
}

async function deleteAnnouncement(req, res, next) {
  try {
    await announcementService.deleteAnnouncement(req.params.id);
    res.json({ success: true, data: null });
  } catch (err) { next(err); }
}

module.exports = { listAnnouncements, createAnnouncement, deleteAnnouncement };
