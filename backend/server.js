const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const bodyParser = require('body-parser');

const cadenceRoutes = require('./routes/cadence');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/cadence', cadenceRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        service: 'Cadence Tracker API'
    });
});

// Default route
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Cadence Tracker API',
        version: '1.0.0',
        endpoints: {
            health: '/health',
            cadence: '/api/cadence',
            getAllCadence: '/api/cadence',
            createCadence: '/api/cadence (POST)',
            getCadenceById: '/api/cadence/:id',
            updateCadence: '/api/cadence/:id (PUT)',
            deleteCadence: '/api/cadence/:id (DELETE)'
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        message: err.message
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Cadence Tracker API Server running on port ${PORT}`);
    console.log(`📱 Health check: http://localhost:${PORT}/health`);
    console.log(`📊 API docs: http://localhost:${PORT}/`);
}); 