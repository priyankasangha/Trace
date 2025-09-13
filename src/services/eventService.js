import prisma from "../prisma/client.js";

/*
create new event in the database
@param {Object} data: from the frontend
*/
export async function createEvent(data, user) {
    if (!data.title || !data.year) {
        throw new Error("title and year are required for event");
    }

    if (!user) {
        throw new Error("user needs to exist");
    }

    const event = await prisma.event.create({
        data: {
            title: data.title,
            description: data.description,
            year: data.year,
            month: data.month,
            day: data.day,
            country: data.country,
            city: data.city,
            place: data.place,
            imageUrls: null,
            userId: user.id,
            tags: null
        }
    });
    return event;
}
