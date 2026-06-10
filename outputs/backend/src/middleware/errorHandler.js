import { v4 as uuidv4 } from 'uuid';
import config from '../config/environment.js';
import logger from '../config/logger.js';

export class ApiError extends Error {
  constructor(statusCode, errorCode, message, isOperational = true, stack = '') {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.isOperational = isOperational;
    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

export const errorConverter = (err, req, res, next) => {
  let error = err;
  if (!(error instanceof ApiError)) {
    const statusCode = error.statusCode || 500;
    const errorCode = error.errorCode || 'INTERNAL_SERVER_ERROR';
    const message = error.message || 'Internal Server Error';
    error = new ApiError(statusCode, errorCode, message, false, err.stack);
  }
  next(error);
};

// eslint-disable-next-line no-unused-vars
export const errorHandler = (err, req, res, next) => {
  let { statusCode, errorCode, message } = err;

  if (config.env === 'production' && !err.isOperational) {
    statusCode = 500;
    errorCode = 'INTERNAL_SERVER_ERROR';
    message = 'Internal Server Error';
  }

  res.locals.errorMessage = err.message;

  const response = {
    errorCode,
    message,
    timestamp: new Date().toISOString(),
    requestId: req.headers['x-request-id'] || uuidv4(),
  };

  if (config.env === 'development') {
    logger.error('API Error: %o', err);
    response.stack = err.stack;
  } else if (statusCode >= 500) {
    logger.error('Critical Server Error: %o', err);
  }

  res.status(statusCode).json(response);
};
export default { ApiError, errorConverter, errorHandler };
