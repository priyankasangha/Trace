import prisma from '../../../prisma/client.js';
import { JourneyRole } from '../../../prisma/client.js';

// returns true if user is a primary owner
export async function isPrimaryJourneyOwner(userId, journeyId) {
  const role = await getUserRoleOnJourney(userId, journeyId);
  return role === JourneyRole.PRIMARY_OWNER;
}

// returns true if a user has any type of ownership: co or primary
export async function isCoOwnerOrPrimaryJourneyOwner(userId, journeyId) {
  const role = await getUserRoleOnJourney(userId, journeyId);
  return role === JourneyRole.PRIMARY_OWNER || role === JourneyRole.CO_OWNER;
}

export async function isJourneyViewer(userId, journeyId) {
  const role = await getUserRoleOnJourney(userId, journeyId);
  return role === JourneyRole.VIEWER;
}

async function getUserRoleOnJourney(userId, journeyId) {
  const participant = await prisma.participant.findUnique({
    where: {
      userId_journeyId: {
        userId,
        journeyId,
      },
    },
  });

  return participant?.role;
}

export function throwPermissionError(hasPermission, message) {
  if (!hasPermission) {
    throw new Error(message);
  }
}
