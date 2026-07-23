const donationService = require("./donation.service");

async function createDonation(req, res, next) {
  try {
    const {
      amount,
      category,
      method,
      reference,
      isAnonymous,
      donorFirstName,
      donorLastName,
      donorPosition,
      donorLocation,
      deviceId,
    } = req.body;

    if (!amount || !category || !method) {
      return res.status(400).json({
        success: false,
        message: "amount, category and method are required",
      });
    }

    const donation = await donationService.createDonation({
      amount,
      category,
      method,
      reference,
      isAnonymous,
      donorFirstName,
      donorLastName,
      donorPosition,
      donorLocation,
      deviceId,
    });
    res.status(201).json({ success: true, data: donation });
  } catch (err) {
    next(err);
  }
}
async function listDonations(req, res, next) {
  try {
    const donations = await donationService.listDonations();
    res.json({ success: true, data: donations });
  } catch (err) {
    next(err);
  }
}

async function updateStatus(req, res, next) {
  try {
    const { status } = req.body;
    if (!["PENDING", "SUCCESS", "FAILED"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "status must be PENDING, SUCCESS, or FAILED",
      });
    }
    const donation = await donationService.updateStatus(req.params.id, status);
    res.json({ success: true, data: donation });
  } catch (err) {
    next(err);
  }
}

module.exports = { createDonation, listDonations, updateStatus };
