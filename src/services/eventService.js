import prisma from "../prisma/client.js";

/*
create new event in the database
@param {Object} data: from the frontend
*/
export async function createEvent(data, user, journeyId) {
    isUserLoggedIn(user);
    await checkJourney(journeyId);
    checkFields(data, user);

    await isUserValid(user, journeyId);

    const event = await prisma.event.create({
        data: {
            title: data.title,
            description: data.description,
            year: data.year,
            month: data.month,
            day: data.day,
            country: data.country,
            city: data.city,
            place: data.place,
            imageUrls: null,
            journey: { connect: { id: journeyId } },
            tags: null
        }
    });
    
    return event;
}

export async function editEvent(data, user, journeyId, eventId) {
    isUserLoggedIn(user);
    await checkJourney(journeyId);
    await doesEventExistInJourney(eventId, journeyId);

    await isUserValid(user, journeyId);

    // keeps fields that are not undefined from user (like only stuff they updated)
     const updateData = Object.fromEntries(
        Object.entries({
            title: data.title,
            description: data.description,
            year: data.year,
            month: data.month,
            day: data.day,
            country: data.country,
            city: data.city,
            place: data.place,
            imageUrls: null,
        }).filter(([_, v]) => v !== undefined)
    );

    // only updated fields get sent
    const updatedEvent = await prisma.event.update({
        where: { id: eventId },
        data: updateData,
    });

    return updatedEvent;
}

export async function getEvent(user, journeyId, eventId) {
    isUserLoggedIn(user);
    await checkJourney(journeyId);
    await doesEventExistInJourney(eventId, journeyId)
    await isUserValid(user, journeyId);

    const event = await prisma.event.findFirst({
        where: { 
            id: eventId,
            journeyId: journeyId
        },
        include: {
            journey: { include: { users: true } },
            tags: true
        }
    });
    return event;
}

export async function deleteEvent(data, user, journeyId, eventId) {
    isUserLoggedIn(user);
    await checkJourney(journeyId);
    const event = await doesEventExistInJourney(eventId, journeyId);

    await isUserValid(user, journeyId);

    await prisma.event.delete({
        where: { 
            id: eventId,
        }
    });
}

// ADD FUNCTION THAT GETS ALL EVENTS FOR A JOURNEY





// HELPERS:

// throws error if event doesn't exist
async function doesEventExistInJourney(eventId, journeyId) {
    const event = await prisma.event.findFirst({
        where: { 
            id: eventId,
            journeyId: journeyId,
         },
        include: { journey: { include: { users: true } } }
    });

    if(!event) {
        throw new Error("event does not exist");
    }
    return event;
}

//throws error if field is wrong to create event
function checkFields(data, user) {
    if (!data.title) {
        throw new Error("your event needs a title");
    }
    if (!data.year) {
        throw new Error("your event needs a year");
    }
}

async function checkJourney(journeyId) {
    const journey = await prisma.journey.findUnique({
        where: { id: journeyId }
    });

    if(!journey) {
        throw new Error("this journey doesn't exist");
    }
}

function isUserLoggedIn(user) {
    if (!user) {
        throw new Error("user must be logged in");
    }
}

// validate if a user is on a journey and is allowed to add an event
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
        throw new Error("this user isn't authorized to change the events");
    }
}
