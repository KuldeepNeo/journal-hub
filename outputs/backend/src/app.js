import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import logger from './config/logger.js';
import { globalLimiter } from './middleware/rateLimiter.js';
import { ApiError, errorConverter, errorHandler } from './middleware/errorHandler.js';
import authRoutes from './routes/authRoutes.js';
import draftRoutes from './routes/draftRoutes.js';

const app = express();

// Set security HTTP headers
app.use(helmet());

// Enable CORS
app.use(cors());

// Parse json request body
app.use(express.json());

// Parse urlencoded request body
app.use(express.urlencoded({ extended: true }));

// Request logging using Morgan streamed to Winston logger
const morganFormat = ':method :url :status :res[content-length] - :response-time ms';
app.use(
  morgan(morganFormat, {
    stream: {
      write: (message) => logger.info(message.trim())
    }
  })
);

// Apply global rate limiting
app.use(globalLimiter);

// Health check API
app.get('/api/v1/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    message: 'Journal Hub API service is active'
  });
});

// Authentication APIs
app.use('/api/v1/auth', authRoutes);

// Draft APIs
app.use('/api/v1/drafts', draftRoutes);

// Fallback for undefined routes -> throw 404 ApiError
app.use((req, res, next) => {
  next(new ApiError(404, 'NOT_FOUND', 'Requested resource not found'));
});

// Convert errors to ApiError if needed
app.use(errorConverter);

// Centralized error handler
app.use(errorHandler);

export default app;
export { app };
