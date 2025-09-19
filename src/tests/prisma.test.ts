import { PrismaClient } from '@prisma/client';
import { describe } from 'node:test';

const prisma = new PrismaClient();

describe('Prisma tests', () => {
  afterAll(async () => {
    await prisma.$disconnect();
  });

  // afterEach(async () => {
  //     await prisma.user.deleteMany();
  // });

  it('creates and fetches a user', async () => {
    console.log('creating filler user');
    const userZero = await prisma.user.create({
      data: {
        name: 'Shrey',
        email: 'shreygan@gmail.com',
      },
    });
    expect(userZero).toBeDefined();
    expect(userZero.name).toBe('Shrey');
    expect(userZero.email).toBe('shreygan@gmail.com');
  });

  it('creates and fetches an event, tag, and user', async () => {
    console.log('creating filler user');
    const userOne = await prisma.user.create({
      data: {
        name: 'Aleesha',
        email: 'aleesha@hotmail.com',
      },
    });

    console.log('creating filler tag');
    const tag = await prisma.tag.create({
      data: {
        name: 'date',
      },
    });

    console.log('creating filler event');
    const event = await prisma.event.create({
      data: {
        title: 'Guildford hangout',
        description: 'hangout',
        year: 2025,
        month: 2,
        country: 'Canada',
        city: 'Surrey',
        place: 'Guilford mall',
        user: { connect: { id: userOne.id } },
        tags: { create: [{ tag: { connect: { id: tag.id } } }] },
      },
      include: {
        tags: { include: { tag: true } },
        user: true,
      },
    });
    expect(userOne).toBeDefined();
    expect(tag).toBeDefined();
    expect(event).toBeDefined();
    expect(event.userId).toBe(userOne.id);
    expect(event.tags.length).toBe(1);
    expect(event.tags[0]).toBeDefined();
    expect(event.tags[0]!.tagId).toBe(tag.id);
  });
});
