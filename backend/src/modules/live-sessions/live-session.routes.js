const express = require('express');
const router = express.Router();
const liveSessionController = require('./live-session.controller');

router.get('/current', liveSessionController.getCurrentLiveSession);
router.post('/', liveSessionController.startLiveSession);
router.post('/:id/end', liveSessionController.endLiveSession);

module.exports = router;
