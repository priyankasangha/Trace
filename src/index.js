// import express to run a web server
import express from 'express';
import session from 'express-session';
import passport from './config/passport.js';
import dotenv from 'dotenv';
import eventRoutes from './routes/events.js';
import journeyRoutes from './routes/journeys.js';

// load .env variables
dotenv.config();

// server object
const app = express();

// parse JSON bodies
app.use(express.json());

// middleware:
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  }
  res.status(401).json({ error: 'you must be logged in' });
}

// session required for passport
app.use(
  session({
    secret: process.env.SESSION_SECRET || 'something_secret_fallback',
    resave: false,
    saveUninitialized: false,
  })
);

// initialize passport and session
app.use(passport.initialize());
app.use(passport.session());

// ----- ROUTES -----

// health check for route
app.get('/', (_req, res) => {
  res.send('Backend is running!');
});


// mount route to add event
app.use('/api/journeys/:journeyId/events', ensureAuthenticated, eventRoutes);
app.use('api/journeys', ensureAuthenticated, journeyRoutes);
// ---- START SERVER ----
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
