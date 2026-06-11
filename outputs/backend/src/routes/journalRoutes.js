import express from 'express';
import journalController from '../controllers/journalController.js';
import journalValidation from '../validation/journalValidation.js';
import authMiddleware from '../middleware/authMiddleware.js';

const router = express.Router();

// Apply auth middleware to all journal routes
router.use(authMiddleware);

router.post(
  '/',
  journalValidation.validate(journalValidation.createJournalSchema),
  journalController.createJournal
);

router.get('/', journalController.listJournals);

router.get('/:journalId', journalController.getJournal);

router.put(
  '/:journalId',
  journalValidation.validate(journalValidation.updateJournalSchema),
  journalController.updateJournal
);

router.delete('/:journalId', journalController.deleteJournal);

export default router;
