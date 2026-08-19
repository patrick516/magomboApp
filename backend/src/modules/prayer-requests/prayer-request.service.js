const prisma = require('../../lib/prisma');

async function createPrayerRequest({ requesterName, isAnonymous, message, deviceId }) {
  return prisma.prayerRequest.create({
    data: {
      requesterName: isAnonymous ? null : requesterName,
      isAnonymous: isAnonymous || false,
      message,
      deviceId,
    },
  });
}

async function listPrayerRequests() {
  return prisma.prayerRequest.findMany({ orderBy: { createdAt: 'desc' } });
}

async function markPrayedFor(id) {
  return prisma.prayerRequest.update({
    where: { id },
    data: { status: 'PRAYED_FOR' },
  });
}

module.exports = { createPrayerRequest, listPrayerRequests, markPrayedFor };
