const express = require('express');
const router = express.Router();
const donationController = require('./donation.controller');
const { authenticateAdmin } = require('../../middleware/auth');

router.post('/', donationController.createDonation);
router.get('/', authenticateAdmin, donationController.listDonations);

module.exports = router;
