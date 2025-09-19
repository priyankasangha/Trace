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
