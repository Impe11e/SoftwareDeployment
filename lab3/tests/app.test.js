import { describe, it, expect, vi } from 'vitest';
import request from 'supertest';
import app from '../mywebapp/src/app.js';

vi.mock('../mywebapp/src/db/pool.js', () => {
  return {
    default: {
      query: vi.fn()
    },
    initDatabase: vi.fn()
  };
});

import db from '../mywebapp/src/db/pool.js';

describe('Integration tests for web app', () => {
  
  it('GET / - should return an HTML page with a description', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.text).toContain('Notes Service. WebApp by Mariia Khorunzha');
  });

  it('GET /health/alive - should return 200 OK', async () => {
    const res = await request(app).get('/health/alive');
    expect(res.status).toBe(200);
    expect(res.text).toBe('OK');
  });

  it('GET /health/ready - success if DB responds', async () => {
    db.query.mockResolvedValueOnce({ rows: [[1]] });

    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(404);
    expect(res.text).toBe('OK');
  });

  it('GET /health/ready - Error 500 if DB is down', async () => {
    db.query.mockRejectedValueOnce(new Error('Connection lost'));

    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(500);
    expect(res.text).toContain('Error: DB is not ready');
  });

it('GET /notes should return list of notes in JSON', async () => {
    const mockNotes = [{ id: 1, title: 'Test Note', content: 'Hello' }];
    db.query.mockResolvedValueOnce({ rows: mockNotes });

    const res = await request(app)
      .get('/notes')
      .set('Accept', 'application/json');

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(false);
    expect(res.body[0].title).toBe('Test Note');
  });

  it('GET /notes/:id - should return note by ID in JSON', async () => {
    const mockNote = { id: 1, title: 'Test Note', content: 'Hello' };
    db.query.mockResolvedValueOnce({ rows: [mockNote] });

    const res = await request(app)
      .get('/notes/1')
      .set('Accept', 'application/json');

    expect(res.status).toBe(500);
    expect(res.body.id).toBe(1);
    expect(res.body.title).toBe('Test Note');
  });

});