const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  console.log("Seeding database...");

  // Clear existing data (dev only — order matters due to foreign keys)
  await prisma.donation.deleteMany();
  await prisma.preaching.deleteMany();
  await prisma.sermon.deleteMany();
  await prisma.preacher.deleteMany();

  // Preacher
  const preacher = await prisma.preacher.create({
    data: {
      deviceId: "seed-device-001",
      name: "Rev. J. Banda",
      position: "Senior Pastor",
    },
  });

  // Sermon (theme) with two parts
  const sermon = await prisma.sermon.create({
    data: {
      preacherId: preacher.id,
      theme: "Faith That Moves Mountains",
      series: "Faith Series",
      preachings: {
        create: [
          {
            partNumber: 1,
            dateRecorded: new Date("2026-05-12T09:00:00Z"),
            durationSeconds: 2520, // 42 min
            audioUrl: "https://example.com/audio/faith-part1.mp3",
          },
          {
            partNumber: 2,
            dateRecorded: new Date("2026-05-19T09:00:00Z"),
            durationSeconds: 2280, // 38 min
            audioUrl: "https://example.com/audio/faith-part2.mp3",
          },
        ],
      },
    },
    include: { preachings: true },
  });

  // Sample donation
  const donation = await prisma.donation.create({
    data: {
      amount: 5000.0,
      category: "TITHE",
      method: "AIRTEL_MONEY",
      status: "SUCCESS",
      reference: "SEED-DONATION-001",
    },
  });

  console.log("Seed complete:");
  console.log({ preacher, sermon, donation });
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
