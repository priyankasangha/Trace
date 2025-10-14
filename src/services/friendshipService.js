import prisma from '../../../prismaClient.js';
import * as JourneyPerms from '../helpers/permissionsHelpers/journeyPermissionsHelpers.js';
import * as UserPerms from '../helpers/permissionsHelpers/userPermissionsHelpers.js';
import * as RoleUtils from '../helpers/utils/roleUtils.js';
import * as FriendshipValidation from '../helpers/serviceHelpers/validationHelpers/friendshipValidationHelpers.js';
import { FriendshipStatus } from '../../../prismaClient.js';

// mutual friendship model schema just for reference 
// TODO: delete after implementing the functions
// model Friendship {
//   id Int @id @default(autoincrement())

//   userId Int
//   friendId Int

//   user User @relation("UserFriendships", fields: [userId], references: [id])
//   friend User @relation("FriendOf", fields: [friendId], references: [id])

//   status FriendshipStatus @default(NONE) // pending, accepted, blocked, NONE

//   @@index([friendId, status]) // composite for make status easy to lookup
//   @@unique([userId, friendId]) // no duplicate friendships
// }

// enum FriendshipStatus {
//   PENDING
//   ACCEPTED
//   BLOCKED
//   NONE
// }


export async function sendFriendRequest(userId, toUserId) {
  await FriendshipValidation.validFriendshipRequest(fromUserId, toUserId);
  return await prisma.friendship.create({
    data: {
        userId: userId,
        friendId: friendId,
        status: FriendshipStatus.PENDING
    }
  });
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