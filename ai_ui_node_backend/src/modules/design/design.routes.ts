import { Router } from 'express';
// 🔥 Changed generateDesign to generateUI to match your controller
import { generateUI, getUserProjects } from './design.controller'; 

const router = Router();

// Your existing generate route (calling generateUI now)
router.post('/generate', generateUI); 

// Your new get projects route
router.get('/projects/:email', getUserProjects);

export default router;