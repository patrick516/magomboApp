const prisma = require("../../lib/prisma");

async function getOverview() {
  const [
    totalPreachers,
    pendingPreachers,
    approvedPreachers,
    totalSermons,
    totalPreachings,
    totalPlaysResult,
    totalDurationResult,
    totalDonationsResult,
    donationsByCategory,
  ] = await Promise.all([
    prisma.preacher.count(),
    prisma.preacher.count({ where: { status: "PENDING" } }),
    prisma.preacher.count({ where: { status: "APPROVED" } }),
    prisma.sermon.count(),
    prisma.preaching.count(),
    prisma.preaching.aggregate({ _sum: { playCount: true } }),
    prisma.preaching.aggregate({ _sum: { durationSeconds: true } }),
    prisma.donation.aggregate({
      _sum: { amount: true },
      _count: true,
      where: { status: "SUCCESS" },
    }),
    prisma.donation.groupBy({
      by: ["category"],
      _sum: { amount: true },
      _count: true,
      where: { status: "SUCCESS" },
    }),
  ]);

  return {
    preachers: {
      total: totalPreachers,
      pending: pendingPreachers,
      approved: approvedPreachers,
    },
    sermons: {
      total: totalSermons,
      totalParts: totalPreachings,
      totalHours:
        Math.round(
          ((totalDurationResult._sum.durationSeconds || 0) / 3600) * 10,
        ) / 10,
    },
    engagement: {
      totalPlays: totalPlaysResult._sum.playCount || 0,
    },
    donations: {
      totalAmount: totalDonationsResult._sum.amount || 0,
      totalCount: totalDonationsResult._count || 0,
      byCategory: donationsByCategory.map((d) => ({
        category: d.category,
        amount: d._sum.amount || 0,
        count: d._count,
      })),
    },
  };
}

async function getActivityOverTime(days = 30) {
  const since = new Date();
  since.setDate(since.getDate() - days);

  const sermons = await prisma.sermon.findMany({
    where: { createdAt: { gte: since } },
    select: { createdAt: true },
  });

  const preachings = await prisma.preaching.findMany({
    where: { createdAt: { gte: since } },
    select: { createdAt: true },
  });

  // Group by date (YYYY-MM-DD)
  const dailyCounts = {};
  for (let i = 0; i < days; i++) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    const key = d.toISOString().split("T")[0];
    dailyCounts[key] = { date: key, sermons: 0, preachings: 0 };
  }

  sermons.forEach((s) => {
    const key = s.createdAt.toISOString().split("T")[0];
    if (dailyCounts[key]) dailyCounts[key].sermons++;
  });

  preachings.forEach((p) => {
    const key = p.createdAt.toISOString().split("T")[0];
    if (dailyCounts[key]) dailyCounts[key].preachings++;
  });

  return Object.values(dailyCounts).sort((a, b) =>
    a.date.localeCompare(b.date),
  );
}

async function getRecentActivity(limit = 10) {
  const recentPreachings = await prisma.preaching.findMany({
    take: limit,
    orderBy: { createdAt: "desc" },
    include: {
      sermon: {
        select: {
          theme: true,
          preacher: { select: { name: true } },
        },
      },
    },
  });

  return recentPreachings.map((p) => ({
    id: p.id,
    theme: p.sermon.theme,
    preacherName: p.sermon.preacher.name,
    partNumber: p.partNumber,
    createdAt: p.createdAt,
  }));
}

module.exports = { getOverview, getActivityOverTime, getRecentActivity };
