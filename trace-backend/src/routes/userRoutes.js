import express from 'express';
import { protectWithApple } from '../middleware/auth.js';
import * as User from '../services/userService.js';

const router = express.Router();

router.use(protectWithApple);

router.get('/profile', async (req, res) => {
  try {
    const profile = await User.getUserProfile(req.user.id);
    res.json(profile);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/profile', async (req, res) => {
  try {
    const updatedProfile = await User.updateUserProfile(req.user.id, req.body);
    res.json(updatedProfile);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/search', async (req, res) => {
  try {
    const targetUser = await User.findUserByEmail(req.query.email);
    res.json(targetUser);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;