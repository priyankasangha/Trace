import prisma from '../../../prisma/client.js';
import { JourneyRole } from '../../../prisma/client.js';
import {
  isPrimaryJourneyOwner,
  isCoOwnerOrPrimaryJourneyOwner,
  isJourneyViewer,
} from '../utils/roleUtils.js';

// users can edit if they're any type of owner on the story
export async function ensureUserCanEditJourney(userId, journeyId) {
  const canEdit = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
  if (!canEdit) {
    throw new Error('User cannot edit this journey');
  }
}

// users can only delete if they're primary
export async function ensureUserCanDeleteJourney(userId, journeyId) {
  const canDelete = await isPrimaryJourneyOwner(userId, journeyId);
  throwPermissionError(canDelete, 'User cannot delete this journey');
}

// as long as they are added with any role on the journey they can view
export async function ensureUserCanViewJourney(userId, journeyId) {
  const isViewer = await isJourneyViewer(userId, journeyId);
  const isOwner = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
  const canViewJourney = isViewer || isOwner;
  throwPermissionError(canViewJourney, 'User cannot view this journey');
}
