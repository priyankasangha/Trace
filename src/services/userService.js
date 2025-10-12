import prisma from "../prisma/client.js";
import { JourneyRole, JourneyVisibility } from "../prisma/client.js";


// note: journeys friendships and friends of happens later
export async function createUser(data) {
    if (!data.email || !data.name) {
        throw new Error("User must have a name and email");
    }

    const user = await prisma.user.create({ 
        data: {
            email: data.email,
            name: data.name,
        },
    });

    return user;
}


export async function updateUserName(userId, newName) {
    if (!newname || newName.trim() === "") {
        throw new Error("Name cannot be empty");
    }

    return prisma.user.update({
        where: { id: userId },
        data: { name: newName},
        include: { 
            favourites: true,
            friendships: true,
            friendsOf: true, 
        },
    });
}

export async function updateProfilePic(userId, profilePicUrl) {
    if (!profilePicUrl || profilePicUrl.trim() === "") {
        throw new Error("Profile Pic URL can't be empty");
    };

    return await prisma.user.update({
        where: { id: userId },
        data: { profilePic: profilePicUrl },
        include: {
            favourites: true,
            friendships: true,
            friendsOf: true,
        }
    });
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


// FUNCTIONS FOR USER FAVOURITES
export async function addUserFavourite(userId, journeyId) {
    const updatedJourney = {
        favourites: {
            connect: { id: journeyId },
        },
    };

    return await prisma.user.update({
        where: { id: userId },
        data: updatedJourney,
        include: { favourites: true },
    });
}

export async function removeUserFavourite(userId, journeyId) {
    const updatedJourney = {
        facourites: {
            disconnect: { id: journeyId },
        },
    };

    return prisma.user.update({
        where: { id: userId },
        data: updatedJourney,
        include: { favourites: true},
    });
}

export async function getUserFavourites(userId) {
    return prisma.user.findUnique({
        where: { id: userId },
        include: { favourites: true },
    });
}






// TO DO: UPDATE USER
// export async function updateUser(id, date) {
//     return prisma.user.update({
//         where: { id },
//         data:
//     })
// }