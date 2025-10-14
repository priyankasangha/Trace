import prisma from '../../../prismaClient.js';

export function validFriendshipRequest(userId, friendId) {
    if (userId === friendId) {
        throw new Error('Users cannot send friend requests to themselves');
    }
}