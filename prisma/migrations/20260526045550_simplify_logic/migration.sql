/*
  Warnings:

  - You are about to drop the column `albumImages` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `anniversaryEnabled` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `city` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `country` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `hiddenFromMe` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `hiddenFromOthers` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `place` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `reminderEnabled` on the `Event` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `Friendship` table. All the data in the column will be lost.
  - You are about to drop the column `startYear` on the `Journey` table. All the data in the column will be lost.
  - You are about to drop the `_UserFavourites` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `updatedAt` to the `Event` table without a default value. This is not possible if the table is not empty.
  - Added the required column `lastCelebratedYear` to the `Journey` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Journey` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "public"."Event" DROP CONSTRAINT "Event_journeyId_fkey";

-- DropForeignKey
ALTER TABLE "public"."_UserFavourites" DROP CONSTRAINT "_UserFavourites_A_fkey";

-- DropForeignKey
ALTER TABLE "public"."_UserFavourites" DROP CONSTRAINT "_UserFavourites_B_fkey";

-- DropIndex
DROP INDEX "public"."Friendship_friendId_status_idx";

-- AlterTable
ALTER TABLE "public"."Event" DROP COLUMN "albumImages",
DROP COLUMN "anniversaryEnabled",
DROP COLUMN "city",
DROP COLUMN "country",
DROP COLUMN "hiddenFromMe",
DROP COLUMN "hiddenFromOthers",
DROP COLUMN "place",
DROP COLUMN "reminderEnabled",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "journal" TEXT,
ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "locationName" TEXT,
ADD COLUMN     "longitude" DOUBLE PRECISION,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "public"."Friendship" DROP COLUMN "status";

-- AlterTable
ALTER TABLE "public"."Journey" DROP COLUMN "startYear",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "lastCelebratedYear" INTEGER NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- DropTable
DROP TABLE "public"."_UserFavourites";

-- DropEnum
DROP TYPE "public"."FriendshipStatus";

-- AddForeignKey
ALTER TABLE "public"."Event" ADD CONSTRAINT "Event_journeyId_fkey" FOREIGN KEY ("journeyId") REFERENCES "public"."Journey"("id") ON DELETE CASCADE ON UPDATE CASCADE;
