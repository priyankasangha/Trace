/*
  Warnings:

  - You are about to drop the column `location` on the `Event` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "public"."Event" DROP COLUMN "location",
ADD COLUMN     "city" TEXT,
ADD COLUMN     "country" TEXT,
ADD COLUMN     "place" TEXT;

-- CreateIndex
CREATE INDEX "EventTag_tagId_idx" ON "public"."EventTag"("tagId");
