-- CreateEnum
CREATE TYPE "PreacherStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterTable
ALTER TABLE "preachers" ADD COLUMN     "status" "PreacherStatus" NOT NULL DEFAULT 'PENDING';
