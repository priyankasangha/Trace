import prisma from '../prisma/client.js';
import { JourneyRole, JourneyVisibility } from '../prisma/client.js';
import {
  isUserLoggedIn,
  doesUserExist,
  isExistingMember,
  isUserPrimary,
  isUserCoOwner,
  checkJourneyFields,
  getUserByEmail,
  getUserById,
} from '../permissionsHelpers.js';

const MAX_FAVOURITED_JOURNIES = 10;

// note: journeys friendships and friends of happens later
export async function createUser(data) {
  if (!data.email || !data.name) {
    throw new Error('User must have a name and email');
  }

  const user = await prisma.user.create({
    data: {
      email: data.email,
      name: data.name,
    },
  });

  return user;
}

export async function deleteUser(userId) {
  await doesUserExist(userId);
  return await prisma.user.delete({
    where: { id: userId },
  });
}

export async function updateUser(userId, data) {
  await doesUserExist(userId);
  // remove undefined or null values to prevent accidental overwrites
  const filteredData = Object.fromEntries(
    Object.entries(data).filter(([_, v]) => v !== null && v !== undefined)
  );

  if (Object.keys(filteredData).length === 0) {
    throw new Error('No valid fields to update');
  }

  return prisma.user.update({
    where: { id: userId },
    data: filteredData,
    include: {
      favourites: true,
      friendships: true,
      friendsOf: true,
    },
  });
}

export async function getFavouriteJourneys(userId) {
  await doesUserExist(userId);
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      favourites: {
        include: {
          participants: true,
          events: true,
        },
        orderBy: { startYear: 'desc' },
      },
    },
  });

  return user.favourites;
}

export async function getUserJourneysByRole(
  userId,
  roleFilter = 'all',
  { skip = 0, take = 10 } = {}
) {
  await doesUserExist(userId);
  let roleCondition = undefined;

  if (roleFilter === 'mine') {
    roleCondition = { role: { in: ['PRIMARY_OWNER', 'CO_OWNER'] } };
  } else if (roleFilter === 'all') {
    roleCondition = { role: { in: ['PRIMARY_OWNER', 'CO_OWNER', 'VIEWER'] } };
  } else if (roleFilter === 'friends') {
    roleCondition = { role: { in: ['VIEWER'] } };
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      journeys: {
        where: roleCondition,
        include: {
          participants: true,
          events: true,
          favouritedBy: { where: { id: userId } },
        },
        skip,
        take,
        orderBy: { startYear: 'desc' },
      },
    },
  });

  return user.journeys;
}

// FUNCTIONS FOR USER FAVOURITES

export async function toggleFavourites(userId, journeyId) {
  await doesUserExist(userId);
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { favourites: { select: { id: true } } },
  });

  if (!user) {
    throw new Error('User not found');
  }

  // boolean that returns true if it is favourited
  const isFavourited = await isJourneyFavouritedByUser(userId, journeyId);
  const isUserOverLimit = await isJourneyOverLimit(userId);

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: {
      favourites: isFavourited
        ? { disconnect: { id: journeyId } }
        : { connect: { id: journeyId } },
    },

    include: {
      favourites: true,
      friendships: true,
      friendsOf: true,
      journeys: true,
    },
  });
  return {
    user: updatedUser,
    action: isFavourited ? 'removed' : 'added',
  };
}

// HELPES:

async function isJourneyFavouritedByUser(userId, journeyId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      favourites: {
        where: { id: journeyId },
        select: { id: true },
      },
    },
  });

  return user?.favourites?.length > 0;
}

// throws error if user is over their limit of favourited journies
async function isJourneyOverLimit(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { favourites: true },
  });

  if (user.favourites.length >= MAX_FAVOURITED_JOURNIES) {
    throw new Error('You can only have 10 favourited journeys');
  }
}
