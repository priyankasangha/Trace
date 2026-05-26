import express from 'express';
import dotenv from 'dotenv';
import userRoutes from './routes/userRoutes.js';
import journeyRoutes from './routes/journeyRoutes.js';
import eventRoutes from './routes/eventRoutes.js';

dotenv.config();

const app = express();

app.use(express.json());

app.get('/', (_req, res) => {
  res.send('Backend is running!');
});

app.use('/api/users', userRoutes);
app.use('/api/journeys', journeyRoutes);
app.use('/api/events', eventRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});