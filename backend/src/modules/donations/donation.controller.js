const donationService = require('./donation.service');

async function createDonation(req, res, next) {
  try {
    const { amount, category, method, reference } = req.body;
    if (!amount || !category || !method) {
      return res.status(400).json({ success: false, message: 'amount, category and method are required' });
    }
    const donation = await donationService.createDonation({ amount, category, method, reference });
    res.status(201).json({ success: true, data: donation });
  } catch (err) { next(err); }
}

async function listDonations(req, res, next) {
  try {
    const donations = await donationService.listDonations();
    res.json({ success: true, data: donations });
  } catch (err) { next(err); }
}

module.exports = { createDonation, listDonations };
