const express = require('express');
const router = express.Router();
const testimonyController = require('./testimony.controller');
const { authenticateAdmin } = require('../../middleware/auth');

router.post('/', testimonyController.createTestimony);
router.get('/', testimonyController.listApprovedTestimonies);
router.get('/admin/all', authenticateAdmin, testimonyController.listAllTestimonies);
router.patch('/:id/status', authenticateAdmin, testimonyController.updateStatus);

module.exports = router;
