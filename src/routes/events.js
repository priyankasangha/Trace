import express from 'express';
import {
  createEvent,
  editEvent,
  deleteEvent,
} from '../services/eventService.js';

const router = express.Router();

// the functions are:

// create new event
router.post('/:journeyId/events', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const eventData = req.body;
    const event = await createEvent(eventData, user, journeyId);
    res.status(201).json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// edit event
router.post('/:journeyId/events/:eventId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const eventId = parseInt(req.params.eventId, 10);
    const eventData = req.body;
    const event = await editEvent(eventData, user, journeyId, eventId);
    res.status(200).json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:journeyId/events/:eventId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const eventId = parseInt(req.params.eventId, 10);
    await deleteEvent(user, journeyId, eventId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// you click on a journey and get all the events in it
router.get('/:journeyId/events', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const viewMode = req.query.viewMode || 'VISIBLE_EVENTS'; // or 'ALL_EVENTS'
    const events = await getAllJourneyEvents(user.id, journeyId, { viewMode });
    res.json(events);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// you click on a specific event to see its details
router.get('/:journeyId/events/:eventId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const viewMode = req.query.viewMode || 'VISIBLE_EVENTS'; // or 'ALL_EVENTS'
    const eventId = parseInt(req.params.eventId, 10);
    const event = await getEvent(user.id, journeyId, eventId, { viewMode });
    res.json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
