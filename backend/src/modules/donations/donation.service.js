const prisma = require('../../lib/prisma');

async function createDonation({ amount, category, method, reference }) {
  return prisma.donation.create({
    data: { amount, category, method, reference, status: 'PENDING' },
  });
}

async function listDonations() {
  return prisma.donation.findMany({ orderBy: { createdAt: 'desc' } });
}

module.exports = { createDonation, listDonations };
