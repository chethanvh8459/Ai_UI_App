import { Router } from 'express';
import { generateUI } from './design.controller';

const router = Router();

// This will create the endpoint: POST /api/design/generate
router.post('/generate', generateUI);

export default router;