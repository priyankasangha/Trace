// tests/services/eventService.test.js
import { jest } from '@jest/globals';
import prismaMock from '../mocks/prismaMock.js';
import * as EventService from '../../src/services/eventService.js';

// -----------------------------
// MOCK PRISMA
// -----------------------------
jest.mock('../../src/prisma/client.js', () => ({
  __esModule: true,
  default: prismaMock,
}));

// -----------------------------
// MOCK JOURNEY PERMISSIONS HELPERS
// -----------------------------
jest.mock(
  '../../src/helpers/permissionsHelpers/journeyPermissionsHelpers.js',
  () => ({
    __esModule: true,
    ensureUserCanEditJourney: jest.fn().mockResolvedValue(true),
    ensureUserCanDeleteJourney: jest.fn().mockResolvedValue(true),
    ensureUserCanViewJourney: jest.fn().mockResolvedValue(true),
  })
);

// -----------------------------
// TEST SUITE
// -----------------------------
describe('EventService', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
  });

  test('should create an event', async () => {
    const eventData = { name: 'Test Event', date: new Date() };
    
    // Mock Prisma create
    prismaMock.event.create.mockResolvedValue({ id: 1, ...eventData });

    const event = await EventService.createEvent(eventData);

    expect(prismaMock.event.create).toHaveBeenCalledWith({ data: eventData });
    expect(event).toEqual({ id: 1, ...eventData });
  });

  test('should throw an error if event creation fails', async () => {
    const eventData = { name: 'Fail Event', date: new Date() };

    prismaMock.event.create.mockRejectedValue(new Error('DB error'));

    await expect(EventService.createEvent(eventData)).rejects.toThrow('DB error');
  });

  // You can add more tests here for other EventService functions
});
