import { NotesService } from '../services/notesService.js';

export const getAllNotes = async (req, res) => {
    try {
        const notes = await NotesService.getAll();

        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.json(notes);
        }

        let html = '<h1>Notes Service</h1><table border="1"><tr><th>ID</th><th>Title</th><th>Info</th></tr>';
        notes.forEach(n => {
            html += `<tr><td>${n.id}</td><td>${n.title}</td><td><a href="/notes/${n.id}">View</a></td></tr>`;
        });
        
        res.setHeader('Content-Type', 'text/html');
        res.send(html + '</table><br><a href="/">Back to Home</a>');

    } catch (err) {
        res.status(500).send(`Error: ${err.message}`);
    }
};

export const getNoteById = async (req, res) => {
    try {
        const note = await NotesService.getById(req.params.id);
        
        if (!note) return res.status(404).send('Note not found');

        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.json(note);
        }

        res.setHeader('Content-Type', 'text/html');
        res.send(`
            <h1>${note.title}</h1>
            <p>${note.content}</p>
            <p><small>Created: ${note.created_at}</small></p>
            <hr><a href="/notes">Back to list</a>
        `);
    } catch (err) {
        res.status(500).send(err.message);
    }
};

export const createNote = async (req, res) => {
    const { title, content } = req.body;
    if (!title || !content) return res.status(400).send('Missing data');

    try {
        await NotesService.create(title, content);
        res.status(201).send('OK');
    } catch (err) {
        res.status(500).send(err.message);
    }
};
