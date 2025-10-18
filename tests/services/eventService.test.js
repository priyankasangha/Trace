import { describe, test, expect, beforeEach, vi } from 'vitest';

// Mock Prisma
vi.mock('../../src/prisma/client.js', () => ({
  default: require('../mocks/prismaMock').default,
}));

// Mock journey permissions helpers
vi.mock(
  '../../src/helpers/permissionsHelpers/journeyPermissionsHelpers.js',
  () => ({
    ensureUserCanEditJourney: vi.fn().mockResolvedValue(true),
    ensureUserCanDeleteJourney: vi.fn().mockResolvedValue(true),
    ensureUserCanViewJourney: vi.fn().mockResolvedValue(true),
  })
);

import prismaMock from '../mocks/prismaMock.js';
import * as EventService from '../../src/services/eventService.js';

describe('EventService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('should create an event', async () => {
    const eventData = { name: 'Test Event', date: new Date() };
    prismaMock.event.create.mockResolvedValue({ id: 1, ...eventData });

    const event = await EventService.createEvent(eventData);

    expect(prismaMock.event.create).toHaveBeenCalledWith({ data: eventData });
    expect(event).toEqual({ id: 1, ...eventData });
  });

  test('should throw an error if creation fails', async () => {
    const eventData = { name: 'Fail Event', date: new Date() };
    prismaMock.event.create.mockRejectedValue(new Error('DB error'));

    await expect(EventService.createEvent(eventData)).rejects.toThrow('DB error');
  });
});
