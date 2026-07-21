const prisma = require("../../lib/prisma");

async function listPreachingsForSermon(sermonId) {
  return prisma.preaching.findMany({
    where: { sermonId },
    orderBy: { partNumber: "asc" },
  });
}

async function createPreaching({
  sermonId,
  dateRecorded,
  durationSeconds,
  audioUrl,
}) {
  const last = await prisma.preaching.findFirst({
    where: { sermonId },
    orderBy: { partNumber: "desc" },
  });
  const nextPart = last ? last.partNumber + 1 : 1;

  return prisma.preaching.create({
    data: {
      sermonId,
      partNumber: nextPart,
      dateRecorded: new Date(dateRecorded),
      durationSeconds,
      audioUrl,
    },
  });
}

async function getPreaching(id) {
  return prisma.preaching.findUnique({ where: { id } });
}

async function incrementPlayCount(id) {
  return prisma.preaching.update({
    where: { id },
    data: { playCount: { increment: 1 } },
  });
}

module.exports = {
  listPreachingsForSermon,
  createPreaching,
  getPreaching,
  incrementPlayCount,
};
