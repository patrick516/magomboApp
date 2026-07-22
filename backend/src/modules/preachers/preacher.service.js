const prisma = require("../../lib/prisma");

// Public: only approved preachers, for the "View Sermons" browse screen
async function listPreachers() {
  return prisma.preacher.findMany({
    where: { status: "APPROVED" },
    include: { _count: { select: { sermons: true } } },
    orderBy: { name: "asc" },
  });
}

// Admin: everyone, including pending/rejected, with full details for review
async function listAllPreachers() {
  return prisma.preacher.findMany({
    include: { _count: { select: { sermons: true } } },
    orderBy: { createdAt: "desc" },
  });
}

async function listPendingPreachers() {
  return prisma.preacher.findMany({
    where: { status: "PENDING" },
    orderBy: { createdAt: "asc" },
  });
}

async function registerPreacher({ id, deviceId, name, position }) {
  if (id) {
    return prisma.preacher.upsert({
      where: { id },
      update: { deviceId, name, position },
      create: { id, deviceId, name, position, status: "PENDING" },
    });
  }
  return prisma.preacher.create({
    data: { deviceId, name, position, status: "PENDING" },
  });
}

async function approvePreacher(id) {
  return prisma.preacher.update({
    where: { id },
    data: { status: "APPROVED" },
  });
}

async function rejectPreacher(id) {
  return prisma.preacher.update({
    where: { id },
    data: { status: "REJECTED" },
  });
}

async function deletePreacher(id) {
  // Delete preachings first (via sermons), then sermons, then the preacher —
  // respects foreign key constraints since there's no onDelete: Cascade set up.
  const sermons = await prisma.sermon.findMany({
    where: { preacherId: id },
    select: { id: true },
  });
  const sermonIds = sermons.map((s) => s.id);

  if (sermonIds.length > 0) {
    await prisma.preaching.deleteMany({
      where: { sermonId: { in: sermonIds } },
    });
    await prisma.sermon.deleteMany({ where: { preacherId: id } });
  }

  return prisma.preacher.delete({ where: { id } });
}

module.exports = {
  listPreachers,
  listAllPreachers,
  listPendingPreachers,
  registerPreacher,
  approvePreacher,
  rejectPreacher,
  deletePreacher,
};
