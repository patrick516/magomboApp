-- AlterTable
ALTER TABLE "donations" ADD COLUMN     "device_id" TEXT,
ADD COLUMN     "donor_first_name" TEXT,
ADD COLUMN     "donor_last_name" TEXT,
ADD COLUMN     "donor_location" TEXT,
ADD COLUMN     "donor_position" TEXT,
ADD COLUMN     "is_anonymous" BOOLEAN NOT NULL DEFAULT false;
