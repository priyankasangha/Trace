import prisma from "../prisma/client.js";
import { JourneyRole, JourneyVisibility } from "../prisma/client.js";
import { 
    isUserLoggedIn,
    isExistingMember,
    isUserPrimary,
    isUserCoOwner,
    checkJourneyFields,
    getUserByEmail,
    getUserById,
} from "../permissionsHelpers.js";

export async function createJourney(data, user) {
    isUserLoggedIn(user);
    checkFields(data);

    const journey = await prisma.journey.create({
        data: {
            title: data.title,
            startYear: data.startYear,
            visibility: data.visibility ?? JourneyVisibility.PRIVATE,
            user: {
                create: {
                    user: { connect: { id: user.id } }, // link existing user
                    role: JourneyRole.PRIMARY_OWNER // assign role at creation
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
    isUserLoggedIn(user);
//    checkFields(data); i may not need this because they don't have to edit all fields here
    if (!(await isUserPrimary(user, journeyId) || await isUserCoOwner(user, journeyId))) {
        throw new Error("user is not authorized to create an event");
    }

      // keeps fields that are not undefined from user (like only stuff they updated)
     const updateData = Object.fromEntries(
        Object.entries({
            title: data.title,
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


export async function deleteJourney(data, user, journeyId) {
    isUserLoggedIn(user);
    if (! await isUserPrimary(user, journeyId)) {
        throw new Error("user is not authorized to make this change");
    }

    await prisma.journey.delete({
        where: { 
            id: journeyId,
        }
    });
}

export async function getAllJourneys(user) {
    isUserLoggedIn(user);

    // find all journeys where this user is a member (owner or viewer)
    const journeys = await prisma.journey.findMany({
        where: {
            user: {
                some: {
                    userId: user.id,
                },
            },
        },
        include: {
            user: true, // include all journey-user relationships
        },
    });

    return journeys;
}

// export async function getJourney(data, user) {
//     isUserLoggedIn(user);
//     await isUserOwner(user); // user must be an owner to do this
//     await isUserViewer(user);
// }

// lets one user add another user as either an owner
export async function addCoOwner(data, user, journeyId) {
    isUserLoggedIn(user);
    await checkJourney(journeyId);
    if (isUserPrimary(user, journeyId)) {
        throw new Error("user is not authorized to make this change");
    }

    const newUser = await getUserByEmail(data.email);
    await isExistingMember(newUser, journeyId);
    const coOwner = await prisma.journeyUser.create({
        data: {
            user: { connect: { id: newUser.id } },
            journey: { connect: { id: journeyId } },
            role: JourneyRole.CO_OWNER,
        },
    });

    return coOwner;
}




// HELPERS: 

// check if user is already part of this journey
async function isExistingMember(userToAdd, journeyId) {
    const existingMembership = await prisma.journeyUser.findUnique({
    where: {
      userId_journeyId: {
        userId: userToAdd.id,
        journeyId: journeyId,
      },
    },
  });

  if (existingMembership) {
    throw new Error("User is already part of this journey");
  }
}

// find users by email
async function getUserByEmail(email) {
    const user = await prisma.user.findUnique({
        where: { email: email },
    });

    if (!user) {
        throw new Error("No user found with that email");
    }

    return user;

}

// check if user is logged in so they can create a journey
function isUserLoggedIn(user) {
    if (!user) {
        throw new Error("user must be logged in");
    }
}

// check if fields are correct to make journey
//throws error if field is wrong to create journey
function checkFields(data) {
    if (!data.title) {
        throw new Error("your journey needs a title");
    }
    if (!data.startYear) {
        throw new Error("your journey needs a year");
    }
}

// validate if a user is a primary on the journey
async function isUserCoOwner(user, journeyId) {
    const member = await prisma.journeyUser.findUnique({
        where: {
            userId_journeyId: {
                userId: user.id,
                journeyId: journeyId
            },
        },
    });

   return member?.role === JourneyRole.CO_OWNER;
}

// validate if a user is a coowner on the journey
async function isUserPrimary(user, journeyId) {
    const member = await prisma.journeyUser.findUnique({
        where: {
            userId_journeyId: {
                userId: user.id,
                journeyId: journeyId
            },
        },
    });

   return member?.role === JourneyRole.PRIMARY_OWNER;
}


