import Joi from 'joi';
import { ApiError } from '../middleware/errorHandler.js';

export const createJournalSchema = Joi.object({
  title: Joi.string().trim().required().messages({
    'any.required': 'REQUIRED_FIELD_MISSING',
    'string.empty': 'REQUIRED_FIELD_MISSING'
  }),
  content: Joi.string().trim().required().messages({
    'any.required': 'CONTENT_REQUIRED',
    'string.empty': 'CONTENT_REQUIRED'
  }),
  entryDate: Joi.date().iso().required().messages({
    'any.required': 'REQUIRED_FIELD_MISSING',
    'date.base': 'INVALID_DATE',
    'date.format': 'INVALID_DATE'
  }),
  categoryId: Joi.string().trim().allow(null, '').optional(),
  tags: Joi.array().items(Joi.string().trim()).optional(),
  isPrivate: Joi.boolean().optional()
});

export const updateJournalSchema = Joi.object({
  title: Joi.string().trim().optional(),
  content: Joi.string().trim().optional().messages({
    'string.empty': 'CONTENT_REQUIRED'
  }),
  entryDate: Joi.date().iso().optional().messages({
    'date.base': 'INVALID_DATE',
    'date.format': 'INVALID_DATE'
  }),
  categoryId: Joi.string().trim().allow(null, '').optional(),
  tags: Joi.array().items(Joi.string().trim()).optional(),
  isPrivate: Joi.boolean().optional(),
  versionNumber: Joi.number().integer().required().messages({
    'any.required': 'VERSION_REQUIRED',
    'number.base': 'VERSION_REQUIRED'
  })
});

export const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, { abortEarly: true });
  if (error) {
    const detail = error.details[0];
    const errorCode = detail.message;
    let statusMsg = detail.message;

    if (errorCode === 'REQUIRED_FIELD_MISSING') {
      statusMsg = `${detail.path[0]} is required`;
    } else if (errorCode === 'CONTENT_REQUIRED') {
      statusMsg = 'Journal content cannot be empty';
    } else if (errorCode === 'INVALID_DATE') {
      statusMsg = 'A valid ISO date is required';
    } else if (errorCode === 'VERSION_REQUIRED') {
      statusMsg = 'Version number is required for updates';
    } else {
      return next(new ApiError(400, 'VALIDATION_FAILURE', error.message));
    }
    return next(new ApiError(400, errorCode, statusMsg));
  }
  req.body = value;
  next();
};

export default {
  createJournalSchema,
  updateJournalSchema,
  validate
};
