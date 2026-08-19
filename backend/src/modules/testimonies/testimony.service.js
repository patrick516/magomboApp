const prisma = require('../../lib/prisma');

async function createTestimony({ authorName, isAnonymous, message, deviceId }) {
  return prisma.testimony.create({
    data: {
      authorName: isAnonymous ? null : authorName,
      isAnonymous: isAnonymous || false,
      message,
      deviceId,
      status: 'PENDING',
    },
  });
}

async function listApprovedTestimonies() {
  return prisma.testimony.findMany({
    where: { status: 'APPROVED' },
    orderBy: { createdAt: 'desc' },
  });
}

async function listAllTestimonies() {
  return prisma.testimony.findMany({ orderBy: { createdAt: 'desc' } });
}

async function updateStatus(id, status) {
  return prisma.testimony.update({ where: { id }, data: { status } });
}

module.exports = { createTestimony, listApprovedTestimonies, listAllTestimonies, updateStatus };
