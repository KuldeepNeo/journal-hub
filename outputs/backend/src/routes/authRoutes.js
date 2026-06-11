import express from 'express';
import authController from '../controllers/authController.js';
import { registerSchema, verifyEmailSchema, validate } from '../validation/authValidation.js';
import { authLimiter } from '../middleware/rateLimiter.js';

const router = express.Router();

// Apply auth rate limiter to all auth routes
router.use(authLimiter);

// Registration Endpoint
router.post('/register', validate(registerSchema), authController.register);

// Verification Endpoint
router.post('/verify-email', validate(verifyEmailSchema), authController.verifyEmail);
router.get('/verify-email', authController.verifyEmailGet);

export default router;
