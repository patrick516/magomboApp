-- CreateEnum
CREATE TYPE "DonationCategory" AS ENUM ('TITHE', 'OFFERING', 'BUILDING_FUND', 'MISSIONS', 'THANKSGIVING', 'OTHER');

-- CreateEnum
CREATE TYPE "DonationStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED');

-- CreateTable
CREATE TABLE "donations" (
    "id" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "category" "DonationCategory" NOT NULL,
    "method" TEXT NOT NULL,
    "status" "DonationStatus" NOT NULL DEFAULT 'PENDING',
    "reference" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "donations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "preachers" (
    "id" TEXT NOT NULL,
    "device_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "position" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "preachers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "preachings" (
    "id" TEXT NOT NULL,
    "sermon_id" TEXT NOT NULL,
    "part_number" INTEGER NOT NULL,
    "date_recorded" TIMESTAMP(3) NOT NULL,
    "duration_seconds" INTEGER NOT NULL,
    "audio_url" TEXT NOT NULL,
    "play_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "preachings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sermons" (
    "id" TEXT NOT NULL,
    "preacher_id" TEXT NOT NULL,
    "theme" TEXT NOT NULL,
    "series" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sermons_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "preachings_sermon_id_part_number_key" ON "preachings"("sermon_id", "part_number");

-- AddForeignKey
ALTER TABLE "preachings" ADD CONSTRAINT "preachings_sermon_id_fkey" FOREIGN KEY ("sermon_id") REFERENCES "sermons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sermons" ADD CONSTRAINT "sermons_preacher_id_fkey" FOREIGN KEY ("preacher_id") REFERENCES "preachers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
