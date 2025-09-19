import express from 'express';

import {
  createJourney,
  editJourney,
  deleteJourney,
} from '../services/journeyService.js';

const router = express.Router();

// create a new journey
router.post('/', async (req, res) => {
  try {
    const user = req.user;
    const journeyData = req.body;
    const journey = await createJourney(journeyData, user);
    res.status(201).json(journey);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// edit a journey
router.put('/:journeyId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    const journeyData = req.body;
    const updatedJourney = await editJourney(journeyData, user, journeyId);
    res.json(updatedJourney);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// delete journey
router.delete('/:journeyId', async (req, res) => {
  try {
    const user = req.user;
    const journeyId = parseInt(req.params.journeyId, 10);
    await deleteJourney({}, user, journeyId);
    res.status(204).send();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
