import prisma from "../prisma/client.js";
import { JourneyRole, JourneyVisibility } from "../prisma/client.js";

export async function createUser(data) {
    if (!data.email || !data.name) {
        throw new Error("User must have a name and email");
    }

    const user = await prisma.user.create({ 
        data: {
            email: data.email,
            name: data.name,
            profilePic: data.profilePic ?? null,
        },
    });

    return user;
}

export async function getUserByEmail(email) {
    const user = await prisma.user.findUnique({
        where: { email },
    });

    if (!user) {
        throw new Error("no user found");
    }
    return user;
}

export async function getUserById(id) {
    const user = await prisma.user.findUnique({
        where: { id },
        include: { journeys: true, friendships: true, friendsOf: true },
    });
    
    if (!user) {
        throw new Error("no user found");
    }

    return user;
}

// TO DO: UPDATE USER
// export async function updateUser(id, date) {
//     return prisma.user.update({
//         where: { id },
//         data:
//     })
// }