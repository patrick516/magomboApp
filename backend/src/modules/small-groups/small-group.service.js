const prisma = require('../../lib/prisma');

async function listSmallGroups() {
  return prisma.smallGroup.findMany({ orderBy: { name: 'asc' } });
}

async function createSmallGroup(data) {
  return prisma.smallGroup.create({ data });
}

async function deleteSmallGroup(id) {
  return prisma.smallGroup.delete({ where: { id } });
}

module.exports = { listSmallGroups, createSmallGroup, deleteSmallGroup };
