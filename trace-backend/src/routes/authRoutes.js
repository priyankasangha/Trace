import express from 'express';
import jwt from 'jsonwebtoken';
import * as userService from '../services/userService.js';

const router = express.Router();

// POST /api/auth/apple — no auth middleware here (this IS the login)
router.post('/apple', async (req, res) => {
  try {
    const { identityToken } = req.body;

    if (!identityToken) {
      return res.status(400).json({ error: 'Missing identityToken' });
    }

    // Decode the Apple identity token to get the user's Apple ID
    const decoded = jwt.decode(identityToken);
    if (!decoded || !decoded.sub) {
      return res.status(400).json({ error: 'Invalid Apple token' });
    }

    const appleUserId = decoded.sub;
    const email = decoded.email || null;

    // Find or create user in your database
    const user = await userService.findOrCreateAppleUser({
      appleUserId,
      email,
    });

    // Issue a long-lived JWT
    const token = jwt.sign(
      { userId: user.id, appleUserId },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({ token });
  } catch (error) {
    console.error('Auth error:', error);
    res.status(500).json({ error: 'Authentication failed' });
  }
});

export default router;