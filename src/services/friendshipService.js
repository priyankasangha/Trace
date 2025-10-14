import prisma from '../../../prismaClient.js';
import * as JourneyPerms from '../helpers/permissionsHelpers/journeyPermissionsHelpers.js';
import * as UserPerms from '../helpers/permissionsHelpers/userPermissionsHelpers.js';
import * as RoleUtils from '../helpers/utils/roleUtils.js';

export async function sendFriendRequest(fromUserId, toUserId) {
  if (fromUserId === toUserId) {
    throw new Error('Users cannot send friend requests to themselves');
  }
}

export async function acceptFriendRequest(userId, friendId) {
  const request = await prisma.friendRequest.findUnique({
    where: { id: userId },
  });
}

export async function rejectFriendRequest(userId, friendId) {
}

export async function getFriends(userId) {

}

export async function getPendingFriendRequests(userId) {

}

export async function getFeiendshipStatus(userId, friendId) {

}