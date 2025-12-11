require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();

// Middleware pour parser le JSON
app.use(express.json());

// Servir l'interface HTML depuis le dossier "public"
app.use(express.static(path.join(__dirname, 'public')));


// Config
const PORT = process.env.PORT || 8080;

// Création du pool de connexions MySQL vers RDS
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Middleware pour parser le JSON
app.use(express.json());

// Route de santé
app.get('/health', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT 1 AS ok');
    res.json({ status: 'ok', db: rows[0].ok });
  } catch (err) {
    console.error('Erreur /health :', err);
    res.status(500).json({ status: 'error', error: 'DB connection failed' });
  }
});

/**
 * CRUD TÂCHES
 *  - GET /tasks           : liste toutes les tâches
 *  - POST /tasks          : crée une tâche
 *  - GET /tasks/:id       : détail d'une tâche
 *  - PUT /tasks/:id       : met à jour une tâche
 *  - DELETE /tasks/:id    : supprime une tâche
 */

// Liste des tâches
app.get('/tasks', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT t.*, u.name AS user_name, u.email AS user_email
       FROM tasks t
       JOIN users u ON t.user_id = u.id
       ORDER BY t.created_at DESC`
    );
    res.json(rows);
  } catch (err) {
    console.error('Erreur GET /tasks :', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// Détail d'une tâche
app.get('/tasks/:id', async (req, res) => {
  const taskId = parseInt(req.params.id, 10);
  if (Number.isNaN(taskId)) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  try {
    const [rows] = await pool.query(
      `SELECT t.*, u.name AS user_name, u.email AS user_email
       FROM tasks t
       JOIN users u ON t.user_id = u.id
       WHERE t.id = ?`,
      [taskId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error('Erreur GET /tasks/:id :', err);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

// Création d'une tâche
app.post('/tasks', async (req, res) => {
  const { user_id, title, description, status, due_date } = req.body;

  if (!user_id || !title) {
    return res.status(400).json({ error: 'user_id and title are required' });
  }

  const validStatus = ['TODO', 'IN_PROGRESS', 'DONE'];
  if (status && !validStatus.includes(status)) {
    return res.status(400).json({ error: 'Invalid status value' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO tasks (user_id, title, description, status, due_date)
       VALUES (?, ?, ?, ?, ?)`,
      [user_id, title, description || null, status || 'TODO', due_date || null]
    );

    const [rows] = await pool.query('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Erreur POST /tasks :', err);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// Mise à jour d'une tâche
app.put('/tasks/:id', async (req, res) => {
  const taskId = parseInt(req.params.id, 10);
  if (Number.isNaN(taskId)) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  const { title, description, status, due_date, user_id } = req.body;

  const validStatus = ['TODO', 'IN_PROGRESS', 'DONE'];
  if (status && !validStatus.includes(status)) {
    return res.status(400).json({ error: 'Invalid status value' });
  }

  try {
    // On met à jour uniquement les champs fournis
    const [result] = await pool.query(
      `UPDATE tasks
       SET title = COALESCE(?, title),
           description = COALESCE(?, description),
           status = COALESCE(?, status),
           due_date = COALESCE(?, due_date),
           user_id = COALESCE(?, user_id)
       WHERE id = ?`,
      [title, description, status, due_date, user_id, taskId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const [rows] = await pool.query('SELECT * FROM tasks WHERE id = ?', [taskId]);
    res.json(rows[0]);
  } catch (err) {
    console.error('Erreur PUT /tasks/:id :', err);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// Suppression d'une tâche
app.delete('/tasks/:id', async (req, res) => {
  const taskId = parseInt(req.params.id, 10);
  if (Number.isNaN(taskId)) {
    return res.status(400).json({ error: 'Invalid task id' });
  }

  try {
    const [result] = await pool.query('DELETE FROM tasks WHERE id = ?', [taskId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.status(204).send();
  } catch (err) {
    console.error('Erreur DELETE /tasks/:id :', err);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
