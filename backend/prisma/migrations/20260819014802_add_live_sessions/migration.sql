-- CreateEnum
CREATE TYPE "LiveSessionStatus" AS ENUM ('LIVE', 'ENDED');

-- CreateTable
CREATE TABLE "live_sessions" (
    "id" TEXT NOT NULL,
    "preacher_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "status" "LiveSessionStatus" NOT NULL DEFAULT 'LIVE',
    "stream_url" TEXT,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ended_at" TIMESTAMP(3),

    CONSTRAINT "live_sessions_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "live_sessions" ADD CONSTRAINT "live_sessions_preacher_id_fkey" FOREIGN KEY ("preacher_id") REFERENCES "preachers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
