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
export async function ensureUserCanEditEvent(userId, journeyId) {
  const role = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
  throwPermissionError(role, 'User cannot edit events in this journey');
}

export async function canUserSeeEvent(userId, journeyId, event, options = {}) {
  const isOwner = await JourneyPerms.isCoOwnerOrPrimaryJourneyOwner(
    userId,
    journeyId
  );
  const viewMode = options.viewMode ?? 'VISIBLE_EVENTS';

  if (isOwner) {
    if (viewMode === 'VISIBLE_EVENTS') {
      return !event.hiddenFromMe;
    }
    return true; // Owner + secret mode shows everything
  } else {
    return !event.hiddenFromOthers; // Viewer sees only public events
  }
}

export async function ensureUserCanSeeEvent(userId, journeyId, event, options = {}) {
  const canSee = await canUserSeeEvent(userId, journeyId, event, options);
  throwPermissionError(canSee, 'User cannot view this event');
}
