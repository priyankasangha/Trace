import prismaMock from "../mocks/prismaMock"; 
import * as EventService from '../../src/services/eventService.js';

jest.mock('../../src/prisma/client.js', () => ({
  __esModule: true,
  default: prismaMock,
}));

test('should create an event', async () => {
    const eventData = { name: 'Test Event', date: new Date() };
    prismaMock.event.create.mockResolvedValue({ id: 1, ...eventData });

    const event = await EventService.createEvent(eventData);

    expect(prismaMock.event.create).toHaveBeenCalledWith({ data: eventData });
    expect(event).toEqual({ id: 1, ...eventData });
});