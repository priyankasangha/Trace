import express from 'express';

import * as Journey from '../services/journeyService.js';
// TODO: actually implement this middleware
import { ensureAuthenticated } from '../middleware/authMiddleware.js';

// methods are:
//
// getMyJournies(userId)
// getOneFriendsPublicJourneys(userId, friendId)
// getMyCompletedJourneys(userId)
const router = express.Router();

// create a new journey
router.post('/', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const data = req.body;
    const journey = await Journey.createJourney(data, user);
    res.status(201).json(journey);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// edit a journey
router.put('/:journeyId', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const data = req.body;
    const updatedJourney = await editJourney(data, user, journeyId);
    res.json(updatedJourney);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// delete journey
router.delete('/:journeyId', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    await deleteJourney(user, journeyId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/completed', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const journeys = await Journey.getMyCompletedJourneys(user.id);
    res.json(journeys);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/me', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const journeys = await Journey.getMyCompletedJourneys(user.id);
    res.json(journeys);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/friend/:friendId', ensureAuthenticated, async (req, res) => {
  try {
    const user = req.user;
    const friendId = parseInt(req.params.friendId, 10);
    const journeys = await Journey.getOneFriendsPublicJourneys(
      user.id,
      friendId
    );
    res.json(journeys);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
