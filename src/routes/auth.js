import express from 'express';
import passport from '../config/passport.js';

const router = express.Router();



app.get(
  '/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

// Google redirects here after authentication
app.get(
  '/google/callback',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    // Successful authentication, redirect home.
    const user = req.user;
    res.send(`Hello ${user?.name}, you serve hella cunt.`);
  }
);

router.get('/me', (req, res) => {
    if (req.isAuthenticated()) {
        res.json(req.user);
    } else {
        res.status(401).json({ error: "Not authenticated"});
    }
});