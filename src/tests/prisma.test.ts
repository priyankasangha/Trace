import { PrismaClient } from '@prisma/client';
import { describe } from 'node:test';

const prisma = new PrismaClient();

describe( 'Prisma tests', () => {

    afterAll(async () => {
        await prisma.$disconnect();
    });

    it('creates an fetches a user', async () => {
        console.log("creating filler user");
        const user = await prisma.user.create({
            data: {
                name: "Shrey",
                email: "shreygan@gmail.com"
            }
        }); 
        expect(user).toBeDefined();
        expect(user.name).toBe("Shrey");
        expect(user.email).toBe("shreygan@gmail.com");
    });

});

// async function main() {
// //   const users = await prisma.user.findMany();
//     console.log("creating filler data");
//     // create user
//     const user = await prisma.user.create({
//         data: {
//             name: "Shrey",
//             email: "shreygan@gmail.com"
//         }
//     });

//     // create tag
//     const tag = await prisma.tag.create({
//         data: {
//             name: "date"
//         }
//     });


//     // create event
//     const event  = await prisma.event.create({
//         data: {
//             title: "first date",
//             description: "first date at tower beach",
//             year: 2025,
//             month: 2,
//             country: "Canada",
//             city: "Vancouver",
//             place: "Tower Beach",
//             user: user,
//             userId: user.id,
//             tags: {
//                 connect: [
//                     { id: tag.id }
//                 ]
//             },
//             include: {
//                 tags: { include: { tag: true } },
//                 user: true 
//             }
//         }
//     });
//     console.log("event created");

//     // get all users with their events and tags
//     const database_users = await prisma.user.findMany({
//         include: {
//             events: {
//                 include: {tags: {include: {tag: true } } }
//             }
//         }
//     });
//     //prints all the users
//     console.log("all users with their events and tags", JSON.stringify(database_users, null, 2));
// }

// main()
//     .catch((e) => { 
//         console.log("error running prisma tests", e);
//     })
//     .finally(async () => {
//         await prisma.$disconnect();
//     });
