const prisma = require('../../lib/prisma');

async function startLiveSession({ preacherId, title }) {
  // End any stale session for this preacher first, so a crashed/forgotten
  // app can't leave a phantom "LIVE" session blocking new ones forever.
  await prisma.liveSession.updateMany({
    where: { preacherId, status: 'LIVE' },
    data: { status: 'ENDED', endedAt: new Date() },
  });

  return prisma.liveSession.create({
    data: {
      preacherId,
      title,
      status: 'LIVE',
      // TODO: replace with the real Facebook watch/embed URL once the
      // Graph API + RTMP publishing flow is wired in.
      streamUrl: null,
    },
  });
}

async function endLiveSession(id) {
  return prisma.liveSession.update({
    where: { id },
    data: { status: 'ENDED', endedAt: new Date() },
  });
}

async function getCurrentLiveSession() {
  return prisma.liveSession.findFirst({
    where: { status: 'LIVE' },
    include: { preacher: { select: { id: true, name: true, position: true } } },
    orderBy: { startedAt: 'desc' },
  });
}

module.exports = { startLiveSession, endLiveSession, getCurrentLiveSession };
