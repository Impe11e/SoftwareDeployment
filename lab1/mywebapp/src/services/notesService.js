import db from '../db/client.js';

export const NotesService = {
    async getAll() {
        const { rows } = await db.query('SELECT id, title FROM notes ORDER BY id');
        return rows;
    },

    async getById(id) {
        const { rows } = await db.query('SELECT * FROM notes WHERE id = $1', [id]);
        return rows[0] || null;
    },

    async create(title, content) {
        return await db.query(
            'INSERT INTO notes (title, content) VALUES ($1, $2)',
            [title, content]
        );
    }
};