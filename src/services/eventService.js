import prisma from '../prisma/client.js';
import { JourneyRole } from '@prisma/client';
import * as JourneyPerms from "../helpers/journeyPermissionsHelper.js";
import * as EventPerms from "../helpers/eventPermissionsHelper.js";
import * as RoleUtils from "../utils/roleUtils";
import * as EventValidation from  '../helpers/serviceHelpers/eventServiceHelpers/eventValidationHelpers.js';

// TODO: MAKE SURE WE DON'T RETURN THE WHOLE EVENT, BUT JUST THE FIELDS WE WANT




// Viewing Modes for Events
export const VIEW_MODES = {
  ALL_EVENTS: "ALL_EVENTS",
  VISIBLE_EVENTS: "VISIBLE_EVENTS"
};

// EVENT CRUD FUNCTIONS

export async function createEvent(data, userId, journeyId) {
  await EventPerms.ensureUserCanAddEvent(userId, journeyId);
  data = EventValidation.validateCreateEventData(data);

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
      coverImage: data.coverImage,
      albumImages: data.albumImages, 
      journey: { connect: { id: journeyId } },
    },
  });

  return event;
}

export async function editEvent(data, userId, journeyId, eventId) {
  await EventPerms.ensureUserCanEditEvent(userId, journeyId);
  data = EventValidation.validateEditEventData(data);

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
      coverImage: data.coverImage,
      albumImages: data.albumImages,
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

 export async function deleteEvent(userId, journeyId, eventId) {
  await EventPerms.ensureUserCanDeleteEvent(userId, journeyId);

  await prisma.event.delete({
    where: { id: eventId },
  });
 }


 // EVENT VIEWING FUNCTIONS 

 // this differs based on the users view/permissions
 export async function getAllJourneyEvents(userId, journeyId, options = {}) {
  await JourneyPerms.ensureUserCanViewJourney(userId, journeyId);

  const events = await prisma.event.findMany({
    where: { journeyId },
    orderBy: [ 
      { year: 'asc' },
      { month: 'asc' },
      { day: 'asc' }
    ],
  });

  const visibleEvents = [];
  for (const event of events) {
    if (await EventPerms.canUserSeeEvent(userId, journeyId, event, options)) {
      visibleEvents.push(event);
    }
  }

  return visibleEvents;
 }


// function that returns event details for events users can view
export async function getEventById(userId, journeyId, eventId, options = {}) {
  await JourneyPerms.ensureUserCanViewJourney(userId, journeyId);

  const event = await prisma.event.findUnique({
    where: { id: eventId },
    include: {
      journey: { include: { participants: true } },
    },
  });

  if (!event) {
    throw new Error("Event not found");
  }

  // check if user can see this specific event
  const canView = await EventPerms.canUserSeeEvent(userId, journeyId, event, options);
  if (!canView) {
    throw new Error("You do not have permission to view this event");
  }

  return event;
}

// just a general function to get any event by Id, no filters involved
export async function getAnyEventById(eventId) {
  const event = await prisma.event.findUnique({
    where: {
      id: eventId,
    },
  });

  if (!event) {
    throw new Error("Event not found");
  }
  return event;
}

