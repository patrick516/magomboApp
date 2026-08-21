const prisma = require("../../lib/prisma");

async function listSmallGroups() {
  return prisma.smallGroup.findMany({ orderBy: { name: "asc" } });
}

async function createSmallGroup(data) {
  return prisma.smallGroup.create({ data });
}

async function deleteSmallGroup(id) {
  return prisma.smallGroup.delete({ where: { id } });
}

async function getSmallGroup(id) {
  return prisma.smallGroup.findUnique({
    where: { id },
    include: { _count: { select: { memberships: true } } },
  });
}

async function joinGroup(groupId, { deviceId, memberName }) {
  return prisma.groupMembership.upsert({
    where: { groupId_deviceId: { groupId, deviceId } },
    update: { memberName },
    create: { groupId, deviceId, memberName },
  });
}

async function leaveGroup(groupId, deviceId) {
  return prisma.groupMembership.deleteMany({
    where: { groupId, deviceId },
  });
}

async function isMember(groupId, deviceId) {
  const membership = await prisma.groupMembership.findUnique({
    where: { groupId_deviceId: { groupId, deviceId } },
  });
  return !!membership;
}

async function listPosts(groupId) {
  return prisma.groupPost.findMany({
    where: { groupId },
    include: { comments: { orderBy: { createdAt: "asc" } } },
    orderBy: { createdAt: "desc" },
  });
}

async function createPost(groupId, { deviceId, authorName, message }) {
  return prisma.groupPost.create({
    data: { groupId, deviceId, authorName, message },
  });
}

async function createComment(postId, { deviceId, authorName, message }) {
  return prisma.groupComment.create({
    data: { postId, deviceId, authorName, message },
  });
}

module.exports = {
  listSmallGroups,
  createSmallGroup,
  deleteSmallGroup,
  getSmallGroup,
  joinGroup,
  leaveGroup,
  isMember,
  listPosts,
  createPost,
  createComment,
};
