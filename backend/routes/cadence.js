const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const fs = require('fs').promises;
const path = require('path');

const DATA_FILE = path.join(__dirname, '../data/cadence.json');

// Utility function to read data from JSON file
async function readCadenceData() {
    try {
        const data = await fs.readFile(DATA_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        // If file doesn't exist, return empty array
        if (error.code === 'ENOENT') {
            return [];
        }
        throw error;
    }
}

// Utility function to write data to JSON file
async function writeCadenceData(data) {
    // Ensure data directory exists
    const dataDir = path.dirname(DATA_FILE);
    await fs.mkdir(dataDir, { recursive: true });

    await fs.writeFile(DATA_FILE, JSON.stringify(data, null, 2));
}

// GET /api/cadence - Get all cadence records
router.get('/', async (req, res) => {
    try {
        const cadenceData = await readCadenceData();
        res.json({
            success: true,
            count: cadenceData.length,
            data: cadenceData
        });
    } catch (error) {
        console.error('Error reading cadence data:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve cadence data'
        });
    }
});

// POST /api/cadence - Create new cadence record
router.post('/', async (req, res) => {
    try {
        const { timestamp, averageCadence, totalSteps, duration } = req.body;

        // Validate required fields
        if (!timestamp || !averageCadence || !totalSteps || !duration) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: timestamp, averageCadence, totalSteps, duration'
            });
        }

        // Create new cadence record
        const newCadenceRecord = {
            id: uuidv4(),
            timestamp: new Date(timestamp).toISOString(),
            averageCadence: parseFloat(averageCadence),
            totalSteps: parseInt(totalSteps),
            duration: parseFloat(duration),
            createdAt: new Date().toISOString()
        };

        // Read existing data
        const cadenceData = await readCadenceData();

        // Add new record
        cadenceData.push(newCadenceRecord);

        // Write back to file
        await writeCadenceData(cadenceData);

        res.status(201).json({
            success: true,
            message: 'Cadence record created successfully',
            data: newCadenceRecord
        });
    } catch (error) {
        console.error('Error creating cadence record:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to create cadence record'
        });
    }
});

// GET /api/cadence/:id - Get specific cadence record
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const cadenceData = await readCadenceData();

        const record = cadenceData.find(item => item.id === id);

        if (!record) {
            return res.status(404).json({
                success: false,
                error: 'Cadence record not found'
            });
        }

        res.json({
            success: true,
            data: record
        });
    } catch (error) {
        console.error('Error retrieving cadence record:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve cadence record'
        });
    }
});

// PUT /api/cadence/:id - Update cadence record
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        const cadenceData = await readCadenceData();
        const recordIndex = cadenceData.findIndex(item => item.id === id);

        if (recordIndex === -1) {
            return res.status(404).json({
                success: false,
                error: 'Cadence record not found'
            });
        }

        // Update the record
        cadenceData[recordIndex] = {
            ...cadenceData[recordIndex],
            ...updates,
            updatedAt: new Date().toISOString()
        };

        // Write back to file
        await writeCadenceData(cadenceData);

        res.json({
            success: true,
            message: 'Cadence record updated successfully',
            data: cadenceData[recordIndex]
        });
    } catch (error) {
        console.error('Error updating cadence record:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update cadence record'
        });
    }
});

// DELETE /api/cadence/:id - Delete cadence record
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const cadenceData = await readCadenceData();
        const recordIndex = cadenceData.findIndex(item => item.id === id);

        if (recordIndex === -1) {
            return res.status(404).json({
                success: false,
                error: 'Cadence record not found'
            });
        }

        // Remove the record
        const deletedRecord = cadenceData.splice(recordIndex, 1)[0];

        // Write back to file
        await writeCadenceData(cadenceData);

        res.json({
            success: true,
            message: 'Cadence record deleted successfully',
            data: deletedRecord
        });
    } catch (error) {
        console.error('Error deleting cadence record:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to delete cadence record'
        });
    }
});

// GET /api/cadence/stats/summary - Get cadence statistics
router.get('/stats/summary', async (req, res) => {
    try {
        const cadenceData = await readCadenceData();

        if (cadenceData.length === 0) {
            return res.json({
                success: true,
                data: {
                    totalRecords: 0,
                    averageCadence: 0,
                    totalSteps: 0,
                    totalDuration: 0
                }
            });
        }

        const totalRecords = cadenceData.length;
        const averageCadence = cadenceData.reduce((sum, record) => sum + record.averageCadence, 0) / totalRecords;
        const totalSteps = cadenceData.reduce((sum, record) => sum + record.totalSteps, 0);
        const totalDuration = cadenceData.reduce((sum, record) => sum + record.duration, 0);

        res.json({
            success: true,
            data: {
                totalRecords,
                averageCadence: Math.round(averageCadence * 100) / 100,
                totalSteps,
                totalDuration: Math.round(totalDuration * 100) / 100
            }
        });
    } catch (error) {
        console.error('Error getting cadence statistics:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to get cadence statistics'
        });
    }
});

module.exports = router; 