import prisma from '../prisma/client.js';

export const VIEW_MODES = {
  ALL_EVENTS: 'ALL_EVENTS',
  SELECT_EVENTS: 'SELECT_EVENTS',
};

async function ensureParticipant(userId, journeyId) {
  const participant = await prisma.participant.findUnique({
    where: {
      userId_journeyId: {
        userId: Number(userId),
        journeyId: Number(journeyId),
      },
    },
  });
  if (!participant) throw new Error('You do not have permission to access this journey.');
}

export async function createEvent(data, user, journeyId) {
  const userId = user.id;
  await ensureParticipant(userId, journeyId);

  return await prisma.event.create({
    data: {
      title: data.title,
      description: data.description,
      year: Number(data.year),
      month: data.month ? Number(data.month) : null,
      day: data.day ? Number(data.day) : null,
      locationName: data.locationName,
      latitude: data.latitude ? parseFloat(data.latitude) : null,
      longitude: data.longitude ? parseFloat(data.longitude) : null,
      coverImage: data.coverImage,
      albumImages: data.albumImages || [],
      journal: data.journal,
      anniversaryEnabled: data.anniversaryEnabled ?? false,
      lastCelebratedYear: data.lastCelebratedYear ? Number(data.lastCelebratedYear) : null,
      isVisibleInHighlights: data.isVisibleInHighlights ?? true,
      journey: { connect: { id: Number(journeyId) } },
      user: { connect: { id: Number(userId) } }
    },
    include: {
      user: {
        select: { id: true, name: true, profilePic: true }
      }
    }
  });
}

export async function editEvent(data, user, journeyId, eventId) {
  const userId = user.id;
  await ensureParticipant(userId, journeyId);

  const updateData = {};
  
  if (data.title !== undefined) updateData.title = data.title;
  if (data.description !== undefined) updateData.description = data.description;
  if (data.coverImage !== undefined) updateData.coverImage = data.coverImage;
  if (data.albumImages !== undefined) updateData.albumImages = data.albumImages;
  if (data.journal !== undefined) updateData.journal = data.journal;
  if (data.locationName !== undefined) updateData.locationName = data.locationName;
  if (data.isVisibleInHighlights !== undefined) updateData.isVisibleInHighlights = data.isVisibleInHighlights;
  if (data.anniversaryEnabled !== undefined) updateData.anniversaryEnabled = data.anniversaryEnabled;

  if (data.year !== undefined) updateData.year = Number(data.year);
  if (data.month !== undefined) updateData.month = data.month ? Number(data.month) : null;
  if (data.day !== undefined) updateData.day = data.day ? Number(data.day) : null;
  if (data.latitude !== undefined) updateData.latitude = data.latitude ? parseFloat(data.latitude) : null;
  if (data.longitude !== undefined) updateData.longitude = data.longitude ? parseFloat(data.longitude) : null;
  if (data.lastCelebratedYear !== undefined) updateData.lastCelebratedYear = data.lastCelebratedYear ? Number(data.lastCelebratedYear) : null;

  return await prisma.event.update({
    where: { 
      id: Number(eventId),
      journeyId: Number(journeyId) 
    },
    data: updateData,
    include: {
      user: {
        select: { id: true, name: true, profilePic: true }
      }
    }
  });
}

export async function deleteEvent(user, journeyId, eventId) {
  const userId = user.id;
  await ensureParticipant(userId, journeyId);

  return await prisma.event.delete({
    where: { 
      id: Number(eventId),
      journeyId: Number(journeyId)
    },
  });
}

export async function getAllJourneyEvents(userId, journeyId, options = {}) {
  await ensureParticipant(userId, journeyId);

  const queryConditions = { journeyId: Number(journeyId) };
  if (options.viewMode === VIEW_MODES.SELECT_EVENTS) {
    queryConditions.isVisibleInHighlights = true;
  }

  return await prisma.event.findMany({
    where: queryConditions,
    orderBy: [
      { year: 'asc' }, 
      { month: 'asc' }, 
      { day: 'asc' }
    ],
    include: {
      user: {
        select: { id: true, name: true, profilePic: true }
      }
    }
  });
}

export async function getEvent(userId, journeyId, eventId) {
  await ensureParticipant(userId, journeyId);

  const event = await prisma.event.findUnique({
    where: { id: Number(eventId) },
    include: {
      user: {
        select: { id: true, name: true, profilePic: true }
      }
    }
  });

  if (!event || event.journeyId !== Number(journeyId)) {
    throw new Error('Event not found within this journey.');
  }

  return event;
}