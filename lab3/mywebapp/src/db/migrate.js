import { initDatabase } from './pool.js';

const runMigration = async () => {
    try {
        await initDatabase();
        console.log('Migration completed successfully.');
        process.exit(0);
    } catch (err) {
        console.error('Migration failed:', err);
        process.exit(1);
    }
};

runMigration();