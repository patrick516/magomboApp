const express = require('express');
const router = express.Router();
const prayerRequestController = require('./prayer-request.controller');
const { authenticateAdmin } = require('../../middleware/auth');

router.post('/', prayerRequestController.createPrayerRequest);
router.get('/', authenticateAdmin, prayerRequestController.listPrayerRequests);
router.post('/:id/prayed', authenticateAdmin, prayerRequestController.markPrayedFor);

module.exports = router;
