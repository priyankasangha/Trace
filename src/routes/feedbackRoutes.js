import express from 'express';
import { feedbackService } from '../services/feedbackService.js';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    const { userId, content, urgency } = req.body;

    if (!userId || !content || !urgency) {
      return res.status(400).json({ error: "Missing required fields (userId, content, urgency)." });
    }

    const newFeedback = await feedbackService.createFeedback({ userId, content, urgency });
    return res.status(201).json(newFeedback);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const feedbacks = await feedbackService.getAllFeedback();
    return res.status(200).json(feedbacks);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

router.patch('/:id/resolve', async (req, res) => {
  try {
    const { id } = req.params;
    const { resolved } = req.body;

    const updatedFeedback = await feedbackService.toggleResolveStatus(id, resolved);
    return res.status(200).json(updatedFeedback);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

export default router;