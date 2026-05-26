import express from 'express';
import { protectWithApple } from '../middleware/auth.js';
import * as Journey from '../services/journeyService.js';

const router = express.Router();

router.use(protectWithApple);

router.post('/', async (req, res) => {
  try {
    const user = req.user;
    const journey = await Journey.createJourney(req.body, user);
    res.status(201).json(journey);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const user = req.user;
    const journeys = await Journey.getAllUserJourneys(user.id);
    res.json(journeys);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:journeyId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const journey = await Journey.getJourneyDetails(user.id, journeyId);
    res.json(journey);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/:journeyId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const updatedJourney = await Journey.editJourney(req.body, user, journeyId);
    res.json(updatedJourney);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:journeyId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    await Journey.deleteJourney(user, journeyId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/:journeyId/participants', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email field is required.' });
    }

    const result = await Journey.addParticipantByEmail(user.id, journeyId, email);
    res.status(201).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:journeyId/participants/:userId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const targetUserId = parseInt(req.params.userId, 10);

    await Journey.removeParticipant(user.id, journeyId, targetUserId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:journeyId/participants', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);

    const participants = await Journey.getJourneyParticipants(user.id, journeyId);
    res.status(200).json(participants);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;