const express = require('express');
const router = express.Router();
const smallGroupController = require('./small-group.controller');
const { authenticateAdmin } = require('../../middleware/auth');

router.get('/', smallGroupController.listSmallGroups);
router.post('/', authenticateAdmin, smallGroupController.createSmallGroup);
router.delete('/:id', authenticateAdmin, smallGroupController.deleteSmallGroup);

module.exports = router;
