const express = require('express');
const router = express.Router();
const donationController = require('./donation.controller');

router.post('/', donationController.createDonation);
router.get('/', donationController.listDonations);

module.exports = router;
