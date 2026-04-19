import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import authRoutes from './modules/auth/auth.routes';
import designRoutes from './modules/design/design.routes'; // <-- Import design routes

const app: Application = express();

app.use(cors());
app.use(express.json());

// Basic Health Route
app.get('/api/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'success', message: 'Node.js Backend is running beautifully!' });
});

// Connect the Routes
app.use('/api/auth', authRoutes);
app.use('/api/design', designRoutes); // <-- Use design routes

export default app;