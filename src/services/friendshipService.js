import prisma from '../../../prismaClient.js';
import * as JourneyPerms from '../helpers/permissionsHelpers/journeyPermissionsHelpers.js';
import * as UserPerms from '../helpers/permissionsHelpers/userPermissionsHelpers.js';
import * as RoleUtils from '../helpers/utils/roleUtils.js';
import * as FriendshipValidation from '../helpers/serviceHelpers/validationHelpers/friendshipValidationHelpers.js';
import { FriendshipStatus } from '../../../prismaClient.js';

// mutual friendship model schema just for reference

export async function sendFriendRequest(userId, friendId) {
  await FriendshipValidation.validFriendshipRequest(userId, friendId);
  return await prisma.friendship.create({
    data: {
      userId: userId,
      friendId: friendId,
      status: FriendshipStatus.PENDING,
    },
  });
}

export async function acceptFriendRequest(userId, friendId) {
  const request = await prisma.friendship.update({
    where: {
      userId_friendId: {
        userId: userId,
        friendId: friendId,
      },
    },
    data: {
      status: FriendshipStatus.ACCEPTED,
    },
  });
  return request;
}

export async function rejectFriendRequest(userId, friendId) {
  const request = await prisma.friendship.update({
    where: {
      userId_friendId: {
        userId: userId,
        friendId: friendId,
      },
    },
    data: {
      status: FriendshipStatus.NONE,
    },
  });
  return request;
}

export async function getMyFriends(userId) {
  const myFriends = await prisma.friendship.findMany({
    where: {
      userId: userId,
      status: FriendshipStatus.ACCEPTED,
    },
  });
  return myFriends;
}

export async function getPendingFriendRequests(userId) {
  const pendingRequests = await prisma.friendship.findMany({
    where: {
      userId: userId,
      status: FriendshipStatus.PENDING,
    },
  });
  return pendingRequests;
}

export async function getFriendshipStatus(userId, friendId) {
  const status = await prisma.friendship.findUnique({
    where: {
      userId_friendId: {
        userId: userId,
        friendId: friendId,
      },
    },
    select: {
      status: true,
    },
  });
  return status;
}
