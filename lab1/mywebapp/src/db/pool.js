import pg from 'pg';
import config from '../config/index.js';

const { Pool } = pg;

const pool = new Pool(config.db);

export const initDatabase = async () => {
    const sql = `
        CREATE TABLE IF NOT EXISTS notes (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    `;
    try {
        await pool.query(sql);
        console.log('Database tables initialized');
    } catch (err) {
        console.error('Migration failed:', err);
        throw err;
    }
};

export default pool;