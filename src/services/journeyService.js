import prisma from "../prisma/client.js";


export async function createJourney(data, user) {
    isUserLoggedIn(user);

    const journey = await prisma.journey.create({
        data: {
            title: data.title,
            startYear: data.startYear,
            user: {
                create: {
                    user: { connect: { id: user.id } }, // link existing user
                    role: "owner" // assign role at creation
                }
            }
        },
        include: {
            user: true, // include JourneyUser rows in result
        }
    });
    
    return journey;
}

export async function editJourney(data, user, journeyId) {
    isUserLoggedIn(user);
    checkFields(data);
    await isUserOwner(user, journeyId);

      // keeps fields that are not undefined from user (like only stuff they updated)
     const updateData = Object.fromEntries(
        Object.entries({
            title: data.title,
            startYear: data.startYear,
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
    await isUserOwner(user, journeyId);

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

// lets one user add another user as either an owner or viewer on a journy
export async function shareJourney(data, user, journeyId) {
    isUserLoggedIn(user);
    await isUserOwner(user); // user must be an owner to do this
    await checkJourney(journeyId);

    const newUser = await getUserByEmail(data.email);
    await isExistingMember(user);
    const newMember = await prisma.journeyUser.create({
        data: {
            user: { connect: { id: newUser.id } },
            journey: { connect: { id: journeyId } },
            role: data.role,
        },
    });

    return newMember;
}




// HELPERS: 

// check if user is already part of this journey
async function isExistingMember(user) {
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

// validate if a user is an owner on the journey
async function isUserOwner(user, journeyId) {
    const member = await prisma.journeyUser.findUnique({
        where: {
            userId_journeyId: {
                userId: user.id,
                journeyId: journeyId
            },
        },
    });

    if (!member || member.role !== "owner") {
        throw new Error("this user isn't authorized as an owner for the journey");
    }
}

// validate if a user a viewer on the journey
async function isUserViewer(user, journeyId) {
    const member = await prisma.journeyUser.findUnique({
        where: {
            userId_journeyId: {
                userId: user.id,
                journeyId: journeyId
            },
        },
    });

    if (!member || member.role !== "viewer") {
        throw new Error("this user isn't authorized as an owner for the journey");
    }
}

