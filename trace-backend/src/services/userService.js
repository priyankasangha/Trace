import prisma from '../prisma/client.js';

const MAX_FAVOURITED_JOURNEYS = 3;

async function ensureUserExists(userId) {
  const user = await prisma.user.findUnique({
    where: { id: Number(userId) },
    select: { id: true },
  });
  if (!user) throw new Error('User profile record not found.');
}

export async function findOrCreateAppleUser(applePayload) {
  const { appleUserId, email } = applePayload;

  if (appleUserId) {
    let user = await prisma.user.findUnique({ where: { appleUserId } });
    if (user) return user;
  }

  if (email) {
    const cleanEmail = email.trim().toLowerCase();
    let user = await prisma.user.findUnique({ where: { email: cleanEmail } });
    if (user) {
      // Attach appleUserId if not set yet
      if (appleUserId && !user.appleUserId) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { appleUserId },
        });
      }
      return user;
    }

    const fallbackName = cleanEmail.split('@')[0];
    return await prisma.user.create({
      data: {
        email: cleanEmail,
        name: fallbackName,
        appleUserId,
        profilePic: null,
      },
    });
  }

  throw new Error('Need either appleUserId or email to find/create user.');
}

export async function findUserById(id) {
  return prisma.user.findUnique({ where: { id: Number(id) } });
}

export async function getUserProfile(userId) {
  const user = await prisma.user.findUnique({
    where: { id: Number(userId) },
    select: { id: true, name: true, email: true, profilePic: true, createdAt: true },
  });
  if (!user) throw new Error('Profile record not found.');
  return user;
}

export async function updateUserProfile(userId, data) {
  const updateData = {};

  if (data.name !== undefined) {
    const trimmedName = data.name.trim();
    if (trimmedName === '') throw new Error('Display name cannot be left blank.');
    updateData.name = trimmedName;
  }
  if (data.profilePic !== undefined) updateData.profilePic = data.profilePic;
  if (Object.keys(updateData).length === 0) throw new Error('No valid profile modifications provided.');

  return await prisma.user.update({
    where: { id: Number(userId) },
    data: updateData,
    select: { id: true, name: true, email: true, profilePic: true }
  });
}

export async function deleteUser(userId) {
  await ensureUserExists(userId);
  return await prisma.user.delete({ where: { id: Number(userId) } });
}

export async function toggleJourneyFavorite(userId, journeyId) {
  await ensureUserExists(userId);
  
  const uId = Number(userId);
  const jId = Number(journeyId);

  const user = await prisma.user.findUnique({
    where: { id: uId },
    select: { favorites: { select: { id: true } } }
  });

  const isFavorited = user.favorites.some(j => j.id === jId);

  if (!isFavorited && user.favorites.length >= MAX_FAVOURITED_JOURNEYS) {
    throw new Error(`You can only pin a maximum of ${MAX_FAVOURITED_JOURNEYS} journeys to your dashboard.`);
  }

  const updatedUser = await prisma.user.update({
    where: { id: uId },
    data: {
      favorites: isFavorited
        ? { disconnect: { id: jId } }
        : { connect: { id: jId } }
    },
    select: {
      id: true,
      favorites: { orderBy: { updatedAt: 'desc' } }
    }
  });

  return {
    favorites: updatedUser.favorites,
    action: isFavorited ? 'removed' : 'added'
  };
}

export async function getFavoriteJourneys(userId) {
  await ensureUserExists(userId);

  const user = await prisma.user.findUnique({
    where: { id: Number(userId) },
    include: {
      favorites: {
        include: {
          participants: {
            include: {
              user: { select: { id: true, name: true, profilePic: true } }
            }
          },
          events: true
        },
        orderBy: { updatedAt: 'desc' }
      }
    }
  });
  return user.favorites;
}

export async function findUserByEmail(email) {
  if (!email) throw new Error('An email string is required for lookup calculations.');

  const user = await prisma.user.findUnique({
    where: { email: email.trim().toLowerCase() },
    select: { id: true, name: true, email: true, profilePic: true }
  });
  if (!user) throw new Error('No account found matching that email address.');
  return user;
}