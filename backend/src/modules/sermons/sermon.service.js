const prisma = require("../../lib/prisma");

async function listSermons({ preacherId, since } = {}) {
  const where = {
    preacher: { status: "APPROVED" }, // hide sermons from unapproved preachers
  };
  if (preacherId) where.preacherId = preacherId;
  if (since) where.createdAt = { gte: new Date(since) };

  return prisma.sermon.findMany({
    where,
    include: {
      preacher: { select: { id: true, name: true, position: true } },
      preachings: { orderBy: { partNumber: "asc" } },
    },
    orderBy: { createdAt: "desc" },
  });
}

async function createSermon({ id, preacherId, theme, series }) {
  if (id) {
    return prisma.sermon.upsert({
      where: { id },
      update: { preacherId, theme, series },
      create: { id, preacherId, theme, series },
    });
  }
  return prisma.sermon.create({ data: { preacherId, theme, series } });
}
async function listAllSermonsAdmin() {
  return prisma.sermon.findMany({
    include: {
      preacher: {
        select: { id: true, name: true, position: true, status: true },
      },
      preachings: { orderBy: { partNumber: "asc" } },
    },
    orderBy: { createdAt: "desc" },
  });
}

async function deleteSermon(id) {
  await prisma.preaching.deleteMany({ where: { sermonId: id } });
  return prisma.sermon.delete({ where: { id } });
}

module.exports = {
  listSermons,
  createSermon,
  listAllSermonsAdmin,
  deleteSermon,
};
