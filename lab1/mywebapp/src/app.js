import express from 'express';
import config from './config/index.js';
import db, { initDatabase } from './db/pool.js';
import * as notesController from './controllers/notesController.js';

const app = express();
app.use(express.json());

await initDatabase();

app.get('/', (req, res) => {
    res.send(`
        <h1>Notes Service. WebApp by Mariia Khorunzha for Lab1</h1>
        <ul>
            <li><a href="/notes">View all notes (GET /notes)</a></li>
            <li><a href="/health/alive">Liveness check</a></li>
            <li><a href="/health/ready">Readiness check</a></li>
        </ul>
    `);
});

app.get('/health/alive', (req, res) => res.status(200).send('OK'));
app.get('/health/ready', async (req, res) => {
    try {
        await db.query('SELECT 1');
        res.status(200).send('OK');
    } catch (e) {
        res.status(500).send(`Error: DB is not ready. ${e.message}`);
    }
});

app.get('/notes', notesController.getAllNotes);
app.get('/notes/:id', notesController.getNoteById);
app.post('/notes', notesController.createNote);

const PORT = config.server?.port;
const HOST = config.server?.host;

app.listen(PORT, HOST, () => {
    console.log(`🚀 Server started on http://${HOST}:${PORT}`);
});