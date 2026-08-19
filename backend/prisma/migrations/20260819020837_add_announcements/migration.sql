-- CreateTable
CREATE TABLE "announcements" (
    "id" TEXT NOT NULL,
    "preacher_id" TEXT,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "event_date" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_preacher_id_fkey" FOREIGN KEY ("preacher_id") REFERENCES "preachers"("id") ON DELETE SET NULL ON UPDATE CASCADE;
