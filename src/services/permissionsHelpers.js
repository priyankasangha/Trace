// authHelpers.js
import prisma from "../prisma/client.js";
import { JourneyRole } from "../prisma/client.js";


export function isUserLoggedIn(user) {
  if (!user) throw new Error("User must be logged in");
}

export async function doesUserExist(userId) {
    const user = await prisma.user.findUnique({
        where: { id: userId },
    });
    if (!user) {
        throw new Error("user does not exist");
    }
}

// check if user is part of journey
export async function isExistingMember(userId, journeyId) {
  const existingMembership = await prisma.journeyUser.findUnique({
    where: { userId_journeyId: { userId, journeyId } },
  });
  if (existingMembership) {
    throw new Error("User is already part of this journey");
  }
}

// validate if a user is primary owner
export async function isUserPrimary(userId, journeyId) {
  const member = await prisma.journeyUser.findUnique({
    where: { userId_journeyId: { userId, journeyId } },
  });
  return member?.role === JourneyRole.PRIMARY_OWNER;
}

// validate if a user is co-owner
export async function isUserCoOwner(userId, journeyId) {
  const member = await prisma.journeyUser.findUnique({
    where: { userId_journeyId: { userId, journeyId } },
  });
  return member?.role === JourneyRole.CO_OWNER;
}

// simple field checker for journeys
export function checkJourneyFields(data) {
  if (!data.title) throw new Error("Your journey needs a title");
  if (!data.startYear) throw new Error("Your journey needs a start year");
}

// fetch user by email
export async function getUserByEmail(email) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error("No user found with that email");
  return user;
}