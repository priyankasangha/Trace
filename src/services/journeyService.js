import prisma from '../prisma/client.js';
import { JourneyRole, JourneyVisibility } from '../prisma/client.js';
import * as JourneyPerms from '../helpers/permissionsHelpers/journeyPermissionsHelpers.js';
import * as DataUtils from '../helpers/utils/dataUtils.js';
import * as JourneyValidations from '../helpers/serviceHelpers/validationHelpers/journeyValidationHelpers.js';
// import {
//   isUserLoggedIn,
//   isExistingMember,
//   isUserPrimary,
//   isUserCoOwner,
//   checkJourneyFields,
//   getUserByEmail,
//   getUserById,
// } from '../permissionsHelpers.js';

import * as RoleUtils from '../helpers/utils/roleUtils.js';
import * as FriendshipValidations from '../helpers/serviceHelpers/validationHelpers/friendshipValidationHelpers.js'; 

// CRUD FUNCTIONS FOR JOURNIES

export async function createJourney(data, user) {
  data = FriendshipValidations.validateCreateJourneyData(data);

  const journey = await prisma.journey.create({
    data: {
      title: data.title,
      startYear: data.startYear,
      description: data.description,
      coverPage: data.coverPage,
      anniversaryEnabled: data.anniversaryEnabled ?? false,
      completed: data.completed ?? false,
      visibility: data.visibility ?? JourneyVisibility.PRIVATE,
      user: {
        create: {
          user: { connect: { id: user.id } }, // link existing user
          role: JourneyRole.PRIMARY_OWNER, // assign role at creation
        },
      },
    },
    include: {
      user: true, // include JourneyUser rows in result
    },
  });

  return journey;
}

// also covers changing the journey visiblity
export async function editJourney(data, user, journeyId) {
  data = FriendshipValidations.validateEditJourneyData(data);
  await JourneyPerms.enureUserCanEditJourney(user.id, journeyId);

  // keeps fields that are not undefined from user (like only stuff they updated)
  const updateData = Object.fromEntries(
    Object.entries({
      title: data.title,
      description: data.descripton,
      coverPage: data.coverPage,
      anniversaryEnabled: data.anniversaryEnabled,
      completed: data.completed,
      startYear: data.startYear,
      visibility: data.visibility,
    }).filter(([_, v]) => v !== undefined)
  );

  // only updated fields get sent
  const updatedJourney = await prisma.journey.update({
    where: { id: journeyId },
    data: updateData,
  });

  return updatedJourney;
}

export async function deleteJourney(user, journeyId) {
  await JourneyPerms.ensureUserCanDeleteJourney(user.id, journeyId);
  await prisma.journey.delete({
    where: {
      id: journeyId,
    },
  });
}

// VISIBILITY FUNCTIONS

export async function getMyJournies(userId) {
   return prisma.participant.findMany({
    where: { 
        userId: userId,
        role: { in: [JourneyRole.PRIMARY_OWNER, JourneyRole.CO_OWNER] },
      },
    include:
      { journey: true },
  });
}

export async function getOneFriendsPublicJourneys(userId, friendId) {
  await FriendshipValidations.ensureIsMutualFriend(userId, friendId);
  return prisma.journey.findMany({
    where: {
      visibility: JourneyVisibility.PUBLIC,
      participants: {
        some: {
          userId: friendId,
        },
      },
    },
    include: {
      participants: true,
    }
  });
}

// TODO: get all freinds's journeys

export async function getMyCompletedJourneys(userId) {
  return prisma.participant.findMany({
    where: { 
        userId: userId,
        role: { in: [JourneyRole.PRIMARY_OWNER, JourneyRole.CO_OWNER] },
        journey: {
          completed: true,
        },
      },
    include:
      { journey: true },
  });
}


// TODO figure out the flow for adding a cowoner
// TODO figure out flow for adding a friend

// lets one user add another user as either an owner
// export async function addCoOwner(data, user, journeyId) {
//   isUserLoggedIn(user);
//   await checkJourney(journeyId);
//   if (isUserPrimary(user, journeyId)) {
//     throw new Error('user is not authorized to make this change');
//   }

//   const newUser = await getUserByEmail(data.email);
//   await isExistingMember(newUser, journeyId);
//   const coOwner = await prisma.journeyUser.create({
//     data: {
//       user: { connect: { id: newUser.id } },
//       journey: { connect: { id: journeyId } },
//       role: JourneyRole.CO_OWNER,
//     },
//   });

//   return coOwner;
// }
