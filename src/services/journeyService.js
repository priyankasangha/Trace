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
    await isUserValid(user, journeyId);

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
    await isUserValid(user, journeyId);

    await prisma.journey.delete({
        where: { 
            id: journeyId,
        }
    });
}

// TO DO: MAKE FUNCTION THAT GETS ALL EVENTS FOR A JOURNEY






// HELPERS: 


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

// validate if a user is on a journey
async function isUserValid(user, journeyId) {
    const member = await prisma.journeyUser.findUnique({
        where: {
            userId_journeyId: {
                userId: user.id,
                journeyId: journeyId
            },
        },
    });

    if (!member || member.role == "viewer") {
        throw new Error("this user isn't authorized to change the journey");
    }
}