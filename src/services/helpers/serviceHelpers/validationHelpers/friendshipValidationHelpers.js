import prisma from '../../../prismaClient.js';
import { FriendshipStatus } from '../../../prisma/client.js';

export function validFriendshipRequest(userId, friendId) {
    if (userId === friendId) {
        throw new Error('Users cannot send friend requests to themselves');
    }
}

export async function ensureIsMutualFriend(userId, friendId) {
    const friendship = await prisma.friendship.findFirst({
        where: {
            userId_friendId: {
                userId: userId,
                friendId: friendId,
            },
        },
    });
    if (!friendship || friendship.status !== FriendshipStatus.ACCEPTED) {
        throw new Error('Users are not friends');
    }
}