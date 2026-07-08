/*
  Warnings:

  - A unique constraint covering the columns `[appleUserId]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "appleUserId" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "User_appleUserId_key" ON "public"."User"("appleUserId");
