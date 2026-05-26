/*
  Warnings:

  - You are about to drop the column `lastCelebratedYear` on the `Journey` table. All the data in the column will be lost.
  - You are about to drop the column `visibility` on the `Journey` table. All the data in the column will be lost.
  - You are about to drop the column `role` on the `Participant` table. All the data in the column will be lost.
  - You are about to drop the `Friendship` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."Friendship" DROP CONSTRAINT "Friendship_friendId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Friendship" DROP CONSTRAINT "Friendship_userId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Participant" DROP CONSTRAINT "Participant_userId_fkey";

-- AlterTable
ALTER TABLE "public"."Event" ADD COLUMN     "albumImages" TEXT[],
ADD COLUMN     "anniversaryEnabled" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "isVisibleInHighlights" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "lastCelebratedYear" INTEGER;

-- AlterTable
ALTER TABLE "public"."Journey" DROP COLUMN "lastCelebratedYear",
DROP COLUMN "visibility";

-- AlterTable
ALTER TABLE "public"."Participant" DROP COLUMN "role";

-- DropTable
DROP TABLE "public"."Friendship";

-- DropEnum
DROP TYPE "public"."JourneyRole";

-- DropEnum
DROP TYPE "public"."JourneyVisibility";

-- AddForeignKey
ALTER TABLE "public"."Participant" ADD CONSTRAINT "Participant_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
