-- CreateEnum
CREATE TYPE "PrayerRequestStatus" AS ENUM ('NEW', 'PRAYED_FOR');

-- CreateEnum
CREATE TYPE "TestimonyStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "prayer_requests" (
    "id" TEXT NOT NULL,
    "requester_name" TEXT,
    "is_anonymous" BOOLEAN NOT NULL DEFAULT false,
    "message" TEXT NOT NULL,
    "status" "PrayerRequestStatus" NOT NULL DEFAULT 'NEW',
    "device_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prayer_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "small_groups" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "meeting_day" TEXT,
    "meeting_time" TEXT,
    "location" TEXT,
    "leader_name" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "small_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "testimonies" (
    "id" TEXT NOT NULL,
    "author_name" TEXT,
    "is_anonymous" BOOLEAN NOT NULL DEFAULT false,
    "message" TEXT NOT NULL,
    "status" "TestimonyStatus" NOT NULL DEFAULT 'PENDING',
    "device_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "testimonies_pkey" PRIMARY KEY ("id")
);
