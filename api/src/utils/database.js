const { Pool } = require('pg');
const logger = require('./logger');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Pool error handler
pool.on('error', (err) => {
    logger.error('Unexpected database error', { error: err.message });
});

// Test connection
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        logger.error('Database connection failed', { error: err.message });
    } else {
        logger.info('✅ Database connected successfully', { time: res.rows[0].now });
    }
});

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool
};
