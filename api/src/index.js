const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const logger = require('./utils/logger');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 5000;

// =============================================================================
// Middleware
// =============================================================================

// Security
app.use(helmet());

// CORS
app.use(cors({
    origin: process.env.CORS_ORIGINS?.split(',') || '*',
    credentials: true
}));

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Request logging
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.path}`, {
        ip: req.ip,
        userAgent: req.get('user-agent')
    });
    next();
});

// Static files for mobile testing
app.use(express.static('public'));

// =============================================================================
// Routes
// =============================================================================

// Health check
app.get(['/health', '/api/health'], (req, res) => {
    res.json({
        status: 'OK',
        service: 'KOTO API',
        version: '0.1.0',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// API routes
app.use('/api/v1/sessions', require('./routes/sessions'));
// app.use('/api/v1/lessons', require('./routes/lessons'));
// app.use('/api/v1/audio', require('./routes/audio'));

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        path: req.path
    });
});

// Error handler
app.use(errorHandler);

// =============================================================================
// Server
// =============================================================================

const server = app.listen(PORT, () => {
    logger.info(`🚀 KOTO API Server running on port ${PORT}`);
    logger.info(`   Environment: ${process.env.NODE_ENV || 'development'}`);
    logger.info(`   Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    logger.info('SIGTERM received, shutting down gracefully...');
    server.close(() => {
        logger.info('Server closed');
        process.exit(0);
    });
});

module.exports = app;
