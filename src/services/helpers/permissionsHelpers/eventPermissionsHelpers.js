import prisma from '../../../prisma/client.js';
import { JourneyRole } from '../../../prisma/client.js';
import {
  isPrimaryJourneyOwner,
  isCoOwnerOrPrimaryJourneyOwner,
  isJourneyViewer,
  throwPermissionError,
} from '../utils/roleUtils.js';

// users can add if they're primary or coowners
export async function ensureUserCanAddEvent(userId, journeyId) {
  const role = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
  throwPermissionError(role, 'User cannot add events in this journey');
}

// can only delete events if you're primary owner
export async function ensureUserCanDeleteEvent(userId, journeyId) {
  const role = await isPrimaryJourneyOwner(userId, journeyId);
  throwPermissionError(role, 'User cannot delete this event');
}

// can edit if you're primary or cowowner
export async function ensureUserCanEdit(userId, journeyId) {
  const role = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
  throwPermissionError(role, 'User cannot edit events in this journey');
}
