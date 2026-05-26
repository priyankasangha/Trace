/*
  Warnings:

  - You are about to drop the column `userId` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the `EventTag` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Tag` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `journeyId` to the `Event` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."JourneyVisibility" AS ENUM ('PUBLIC', 'PRIVATE');

-- CreateEnum
CREATE TYPE "public"."JourneyRole" AS ENUM ('PRIMARY_OWNER', 'CO_OWNER', 'VIEWER');

-- CreateEnum
CREATE TYPE "public"."FriendshipStatus" AS ENUM ('PENDING', 'ACCEPTED', 'BLOCKED', 'NONE');

-- DropForeignKey
ALTER TABLE "public"."Event" DROP CONSTRAINT "Event_userId_fkey";

-- DropForeignKey
ALTER TABLE "public"."EventTag" DROP CONSTRAINT "EventTag_eventId_fkey";

-- DropForeignKey
ALTER TABLE "public"."EventTag" DROP CONSTRAINT "EventTag_tagId_fkey";

-- AlterTable
ALTER TABLE "public"."Event" DROP COLUMN "userId",
ADD COLUMN     "anniversaryEnabled" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "hiddenFromMe" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "hiddenFromOthers" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "journeyId" INTEGER NOT NULL,
ADD COLUMN     "reminderEnabled" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "profilePic" TEXT;

-- DropTable
DROP TABLE "public"."EventTag";

-- DropTable
DROP TABLE "public"."Tag";

-- CreateTable
CREATE TABLE "public"."Journey" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "startYear" INTEGER NOT NULL,
    "visibility" "public"."JourneyVisibility" NOT NULL DEFAULT 'PRIVATE',
    "coverPage" TEXT,
    "completed" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Journey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Participant" (
    "userId" INTEGER NOT NULL,
    "journeyId" INTEGER NOT NULL,
    "role" "public"."JourneyRole" NOT NULL,

    CONSTRAINT "Participant_pkey" PRIMARY KEY ("userId","journeyId")
);

-- CreateTable
CREATE TABLE "public"."Friendship" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "friendId" INTEGER NOT NULL,
    "status" "public"."FriendshipStatus" NOT NULL DEFAULT 'NONE',

    CONSTRAINT "Friendship_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."_UserFavourites" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,

    CONSTRAINT "_UserFavourites_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE INDEX "Participant_journeyId_idx" ON "public"."Participant"("journeyId");

-- CreateIndex
CREATE INDEX "Friendship_friendId_status_idx" ON "public"."Friendship"("friendId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Friendship_userId_friendId_key" ON "public"."Friendship"("userId", "friendId");

-- CreateIndex
CREATE INDEX "_UserFavourites_B_index" ON "public"."_UserFavourites"("B");

-- AddForeignKey
ALTER TABLE "public"."Participant" ADD CONSTRAINT "Participant_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Participant" ADD CONSTRAINT "Participant_journeyId_fkey" FOREIGN KEY ("journeyId") REFERENCES "public"."Journey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Event" ADD CONSTRAINT "Event_journeyId_fkey" FOREIGN KEY ("journeyId") REFERENCES "public"."Journey"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Friendship" ADD CONSTRAINT "Friendship_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Friendship" ADD CONSTRAINT "Friendship_friendId_fkey" FOREIGN KEY ("friendId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."_UserFavourites" ADD CONSTRAINT "_UserFavourites_A_fkey" FOREIGN KEY ("A") REFERENCES "public"."Journey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."_UserFavourites" ADD CONSTRAINT "_UserFavourites_B_fkey" FOREIGN KEY ("B") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
