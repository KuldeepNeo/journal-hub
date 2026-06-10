import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import db from './db.js';
import logger from './logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const initDatabase = async (seed = false) => {
  try {
    logger.info('Initializing database schema...');

    // Load schema.sql and execute batch
    const schemaPath = path.resolve(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await db.exec(schemaSql);
    logger.info('Database schema initialized successfully.');

    // Load seeds.sql if requested
    if (seed) {
      logger.info('Seeding mock database records...');
      const seedsPath = path.resolve(__dirname, 'seeds.sql');
      const seedsSql = fs.readFileSync(seedsPath, 'utf8');
      await db.exec(seedsSql);
      logger.info('Database seeding completed successfully.');
    }
  } catch (error) {
    logger.error('Error during database initialization: %o', error);
    throw error;
  }
};

// Check if run directly from command line (e.g. node initDb.js --seed)
const runAsScript = process.argv[1] && (process.argv[1] === __filename || process.argv[1].endsWith('initDb.js'));

if (runAsScript) {
  const seed = process.argv.includes('--seed') || process.argv.includes('-s');
  initDatabase(seed)
    .then(() => {
      logger.info('Database initialization script finished successfully.');
      return db.close();
    })
    .then(() => {
      process.exit(0);
    })
    .catch((err) => {
      logger.error('Database initialization script failed: %o', err);
      process.exit(1);
    });
}

export default initDatabase;
