import { PrimsaClient } from '@primsa/client';

const prisma = new PrimsaClient();

async function main() {
    const users = await prisma.user.findMany();
    console.log(users);
}

try {
    main();
} catch (error) {
    console.log("error running prisma test:", error);
} finally (async() => ) {
    await prisma.$disconnect();
}