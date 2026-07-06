import prisma from '../prisma/client.js';

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

export async function createJourney(data, user) {
  const userId = user.id;
  return await prisma.journey.create({
    data: {
      title: data.title,
      description: data.description,
      coverPage: data.coverPage,
      completed: data.completed ?? false,
      startYear: data.startYear ?? null,
      startMonth: data.startMonth ?? null,
      startDay: data.startDay ?? null,
      endYear: data.endYear ?? null,
      endMonth: data.endMonth ?? null,
      endDay: data.endDay ?? null,
      participants: {
        create: {
          userId: Number(userId),
        },
      },
    },
  });
}

export async function getAllUserJourneys(userId) {
  return await prisma.journey.findMany({
    where: {
      participants: {
        some: {
          userId: Number(userId),
        },
      },
    },
    orderBy: { updatedAt: 'desc' },
  });
}

export async function getJourneyDetails(userId, journeyId) {
  await ensureParticipant(userId, journeyId);

  const journey = await prisma.journey.findUnique({
    where: { id: Number(journeyId) },
  });
  if (!journey) throw new Error('Journey not found.');
  return journey;
}

export async function editJourney(data, user, journeyId) {
  const userId = user.id;
  await ensureParticipant(userId, journeyId);

  const updateData = {};
  if (data.title !== undefined) updateData.title = data.title;
  if (data.description !== undefined) updateData.description = data.description;
  if (data.coverPage !== undefined) updateData.coverPage = data.coverPage;
  if (data.completed !== undefined) updateData.completed = data.completed;
  if (data.startYear !== undefined) updateData.startYear = data.startYear;
  if (data.startMonth !== undefined) updateData.startMonth = data.startMonth;
  if (data.startDay !== undefined) updateData.startDay = data.startDay;
  if (data.endYear !== undefined) updateData.endYear = data.endYear;
  if (data.endMonth !== undefined) updateData.endMonth = data.endMonth;
  if (data.endDay !== undefined) updateData.endDay = data.endDay;

  return await prisma.journey.update({
    where: { id: Number(journeyId) },
    data: updateData,
  });
}

export async function deleteJourney(user, journeyId) {
  const userId = user.id;
  await ensureParticipant(userId, journeyId);

  return await prisma.journey.delete({
    where: { id: Number(journeyId) },
  });
}

export async function addParticipantByEmail(currentUserId, journeyId, email) {
  await ensureParticipant(currentUserId, journeyId);

  const targetUser = await prisma.user.findUnique({
    where: { email: email.trim().toLowerCase() },
  });
  if (!targetUser) throw new Error('No user found with that email address.');

  const existingParticipant = await prisma.participant.findUnique({
    where: {
      userId_journeyId: {
        userId: targetUser.id,
        journeyId: Number(journeyId),
      },
    },
  });
  if (existingParticipant) throw new Error('User is already a collaborator on this journey.');

  return await prisma.participant.create({
    data: {
      userId: targetUser.id,
      journeyId: Number(journeyId),
    },
    include: {
      user: {
        select: { id: true, name: true, email: true, profilePic: true },
      },
    },
  });
}

export async function removeParticipant(currentUserId, journeyId, targetUserId) {
  await ensureParticipant(currentUserId, journeyId);

  const count = await prisma.participant.count({
    where: { journeyId: Number(journeyId) },
  });
  if (count <= 1) {
    throw new Error('Cannot remove the last participant from a journey.');
  }

  return await prisma.participant.delete({
    where: {
      userId_journeyId: {
        userId: Number(targetUserId),
        journeyId: Number(journeyId),
      },
    },
  });
}

export async function getJourneyParticipants(currentUserId, journeyId) {
  await ensureParticipant(currentUserId, journeyId);

  return await prisma.participant.findMany({
    where: { journeyId: Number(journeyId) },
    include: {
      user: {
        select: { id: true, name: true, email: true, profilePic: true },
      },
    },
  });
}