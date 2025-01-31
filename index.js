const express = require('express');
const { Pool } = require('pg');

const app = express();

// Lee variables de entorno
const {
  DB_HOST,
  DB_NAME,
  DB_USER,
  DB_PASS
} = process.env;

// Si usas sockets de Cloud SQL:
//   host: `/cloudsql/${DB_HOST}`
// Para IP privada (por ejemplo, 10.0.0.3):
//   host: DB_HOST

const pool = new Pool({
  user: DB_USER,
  host: `/cloudsql/${DB_HOST}`,  
  database: DB_NAME,
  password: DB_PASS,
  port: 5432
});

app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching users');
  }
});

app.get('/', (req, res) => {
  res.send('API is running...');
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});