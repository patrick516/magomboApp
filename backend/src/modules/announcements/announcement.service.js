const prisma = require('../../lib/prisma');

async function listAnnouncements() {
  return prisma.announcement.findMany({
    include: { preacher: { select: { id: true, name: true, position: true } } },
    orderBy: { createdAt: 'desc' },
  });
}

async function createAnnouncement({ preacherId, title, body, eventDate }) {
  return prisma.announcement.create({
    data: {
      preacherId: preacherId || null,
      title,
      body,
      eventDate: eventDate ? new Date(eventDate) : null,
    },
  });
}

async function deleteAnnouncement(id) {
  return prisma.announcement.delete({ where: { id } });
}

module.exports = { listAnnouncements, createAnnouncement, deleteAnnouncement };
