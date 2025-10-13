import prisma from '../prisma/client.js';
import { JourneyRole } from '@prisma/client';

/*
create new event in the database
@param {Object} data: from the frontend
*/
export async function createEvent(data, user, journeyId) {
  isUserLoggedIn(user);
  checkFields(data, user);
  await checkJourney(journeyId);
  await assertCanModifyEvents(user, journeyId);

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
    },
  });

  return event;
}

export async function editEvent(data, user, journeyId, eventId) {
  isUserLoggedIn(user);
  await checkJourney(journeyId);
  await doesEventExistInJourney(eventId, journeyId);
  await assertCanModifyEvents(user, journeyId);

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
      hiddenFromMe: data.hiddenFromMe,
      hiddenFromOthers: data.hiddenFromOthers,
      anniversaryEnabled: data.anniversaryEnabled,
      reminderEnabled: data.reminderEnabled,
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
  await doesEventExistInJourney(eventId, journeyId);
  await assertCanModifyEvents(user, journeyId);

  const event = await prisma.event.findFirst({
    where: {
      id: eventId,
      journeyId: journeyId,
    },
    include: {
      journey: { include: { users: true } },
      tags: true,
    },
  });
  return event;
}

// gets all events in journey
// if they're coowner or primary owner get all events except hiddenfromme
// if they're a viewer, get all events except hiddenfromothers
export async function getAllJourneyEvents(user, journeyId) {
  isUserLoggedIn(user);
  await checkJourney(journeyId);
  const role = await getUserRole(user, journeyId);
  if (role == JourneyRole.VIEWER) {
    return getAllEventsForViewer(journeyId);
  }
  return getAllEventsForPrimaryAndCoOwner(journeyId);
}


export async function deleteEvent(user, journeyId, eventId) {
  isUserLoggedIn(user);
  await checkJourney(journeyId);
  await doesEventExistInJourney(eventId, journeyId);
  await assertCanModifyEvents(user, journeyId);

  await prisma.event.delete({
    where: {
      id: eventId,
    },
  });
}

// ADD FUNCTION THAT GETS ALL EVENTS FOR A JOURNEY

// HELPERS:

// gets events for primary/coowners:
async function getAllEventsForPrimaryAndCoOwner(journeyId) {
  const events = await prisma.event.findMany({
    where: { 
      journeyId: journeyId,
      hiddenFromMe: false, 
    },
    orderBy: [
      { year: "asc" },
      { month: "asc" },
      { day: "asc" },
    ],
  });
  return events;
}

async function getAllEventsForViewer(journeyId) {
  const events = await prisma.event.findMany({
    where: { 
      journeyId: journeyId,
      hiddenFromOthers: false, 
    },
    orderBy: [
      { year: "asc" },
      { month: "asc" },
      { day: "asc" },
    ],
  });
  return events;
}



// throws error if event doesn't exist
async function doesEventExistInJourney(eventId, journeyId) {
  const event = await prisma.event.findFirst({
    where: {
      id: eventId,
      journeyId: journeyId,
    },
    include: { journey: { include: { users: true } } },
  });

  if (!event) {
    throw new Error('event does not exist');
  }
  return event;
}

//throws error if field is wrong to create event
function checkFields(data, user) {
  if (!data.title) {
    throw new Error('your event needs a title');
  }
  if (!data.year) {
    throw new Error('your event needs a year');
  }
}

async function checkJourney(journeyId) {
  const journey = await prisma.journey.findUnique({
    where: { id: journeyId },
  });

  if (!journey) {
    throw new Error("this journey doesn't exist");
  }
}

function isUserLoggedIn(user) {
  if (!user) {
    throw new Error('user must be logged in');
  }
}

async function assertCanModifyEvents(user, journeyId) {
  const role = await getUserRole(user, journeyId);
  if (![JourneyRole.PRIMARY_OWNER, JourneyRole.CO_OWNER].includes(role)) {
    throw new Error("user is not authorized to modify events");
  }
}

async function getUserRole(user, journeyId) {
  const membership = await prisma.journeyUser.findUnique({
    where: {
      userId_journeyId: {
        userId: user.id,
        journeyId: journeyId,
      },
    },
    select: { role: true },
  });

  if (!membership) {
    throw new Error("User is not part of this journey");
  }

  return membership.role;
}

