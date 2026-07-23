const prisma = require("../../lib/prisma");

async function createDonation({
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
}) {
  return prisma.donation.create({
    data: {
      amount,
      category,
      method,
      reference,
      status: "PENDING",
      isAnonymous: isAnonymous || false,
      // If anonymous, never persist identifying details even if the client sent them
      donorFirstName: isAnonymous ? null : donorFirstName,
      donorLastName: isAnonymous ? null : donorLastName,
      donorPosition: isAnonymous ? null : donorPosition,
      donorLocation: isAnonymous ? null : donorLocation,
      deviceId,
    },
  });
}
async function listDonations() {
  return prisma.donation.findMany({ orderBy: { createdAt: "desc" } });
}

async function updateStatus(id, status) {
  return prisma.donation.update({
    where: { id },
    data: { status },
  });
}

module.exports = { createDonation, listDonations, updateStatus };
