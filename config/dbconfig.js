const { Pool } = require('pg');
const dotenv = require('dotenv')

dotenv.config()

const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASS || '123456',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT|| 5432,
    database: process.env.DB_NAME
});

module.exports = pool