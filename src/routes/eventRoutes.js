import express from 'express';
import { protectWithApple } from '../middleware/auth.js';
import * as Event from '../services/eventService.js';

const router = express.Router();

router.use(protectWithApple);

router.post('/:journeyId/events', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    
    const event = await Event.createEvent(req.body, user, journeyId);
    res.status(201).json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/:journeyId/events/:eventId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const eventId = parseInt(req.params.eventId, 10);
    
    const event = await Event.editEvent(req.body, user, journeyId, eventId);
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
    
    await Event.deleteEvent(user, journeyId, eventId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:journeyId/events', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const viewMode = req.query.viewMode || Event.VIEW_MODES.ALL_EVENTS;
    
    const events = await Event.getAllJourneyEvents(user.id, journeyId, { viewMode });
    res.json(events);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:journeyId/events/:eventId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const eventId = parseInt(req.params.eventId, 10);
    
    const event = await Event.getEvent(user.id, journeyId, eventId);
    res.json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;