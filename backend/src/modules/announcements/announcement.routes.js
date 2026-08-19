const express = require('express');
const router = express.Router();
const announcementController = require('./announcement.controller');
const { authenticateAdmin } = require('../../middleware/auth');

router.get('/', announcementController.listAnnouncements);
router.post('/', announcementController.createAnnouncement);
router.delete('/:id', authenticateAdmin, announcementController.deleteAnnouncement);

module.exports = router;
