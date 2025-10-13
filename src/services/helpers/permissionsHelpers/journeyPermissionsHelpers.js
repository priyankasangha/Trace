import prisma from "../../../prisma/client.js";
import { JourneyRole } from "../../../prisma/client.js";


// functions that return booleans

// returns true if user is a primary owner
export async function isPrimaryJourneyOwner(userId, journeyId) {
    const role = await getUserRoleOnJourney(userId, journeyId);
    return role === JourneyRole.PRIMARY_OWNER
}


// returns true if a user has any type of ownership: co or primary
export async function isCoOwnerOrPrimaryJourneyOwner(userId, journeyId) {
    const role = await getUserRoleOnJourney(userId, journeyId);
    return (role === JourneyRole.PRIMARY_OWNER ||
        role === JourneyRole.CO_OWNER
    );
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


// users can edit if they're any type of owner on the story
export async function ensureUserCanEditJourney(userId, journeyId) {
    const canEdit = await isCoOwnerOrPrimaryJourneyOwner(userId, journeyId);
    if (!canEdit) {
        throw new Error("User cannot edit this journey");
    }
}

export async function ensureUserCanDeleteJourney(userId, journeyId) {
    const canDelete = await isPrimaryJourneyOwner(userId, journeyId);
    if (!canDelete) {
        throw new Error("User cannot delete this journey");
    }
}

export async function ensureUserCanViewJourney(userId, journeyId) {
    const role = await getUserRoleOnJourney(userId, journeyId);
    if (!role) {
        throw new Error("User cannot view this journey");
    }
}

