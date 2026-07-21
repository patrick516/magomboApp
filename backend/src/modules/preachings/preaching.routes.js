const express = require('express');
const router = express.Router();
const preachingController = require('./preaching.controller');

router.get('/:id/audio', preachingController.getAudio);
router.post('/:id/play', preachingController.incrementPlayCount);

module.exports = router;
