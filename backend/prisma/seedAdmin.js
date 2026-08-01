const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash("ChangeMe123!", 10);
  const admin = await prisma.admin.upsert({
    where: { email: "admin@magombo.church" },
    update: {},
    create: {
      email: "admin@magombo.church",
      passwordHash,
      name: "Church Admin",
    },
  });

  console.log("Admin ready:", admin);
}

main()
  .catch((e) => {
    console.error("Admin seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
