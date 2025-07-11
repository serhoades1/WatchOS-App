# Cadence Tracker - Backend API

A RESTful API server for storing and retrieving cadence tracking data from the WatchOS Cadence Tracker app.

## Features

- **REST API**: Full CRUD operations for cadence data
- **JSON Storage**: Simple file-based data persistence
- **Statistics**: Summary statistics for tracked sessions
- **CORS Enabled**: Cross-origin resource sharing support
- **Security**: Helmet.js for security headers
- **Logging**: Morgan for request logging

## Requirements

- **Node.js**: 16.0 or later
- **npm**: 8.0 or later

## Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   npm start
   ```

   Or for development with auto-restart:
   ```bash
   npm run dev
   ```

## API Endpoints

### Base URL
```
http://localhost:3000
```

### Health Check
```
GET /health
```
Returns server status and timestamp.

### Cadence Data Endpoints

#### Get All Cadence Records
```
GET /api/cadence
```
Returns all stored cadence tracking sessions.

**Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "uuid-here",
      "timestamp": "2024-01-01T12:00:00.000Z",
      "averageCadence": 180.5,
      "totalSteps": 1250,
      "duration": 600.5,
      "createdAt": "2024-01-01T12:00:00.000Z"
    }
  ]
}
```

#### Create New Cadence Record
```
POST /api/cadence
```

**Request Body:**
```json
{
  "timestamp": "2024-01-01T12:00:00.000Z",
  "averageCadence": 180.5,
  "totalSteps": 1250,
  "duration": 600.5
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cadence record created successfully",
  "data": {
    "id": "uuid-here",
    "timestamp": "2024-01-01T12:00:00.000Z",
    "averageCadence": 180.5,
    "totalSteps": 1250,
    "duration": 600.5,
    "createdAt": "2024-01-01T12:00:00.000Z"
  }
}
```

#### Get Specific Cadence Record
```
GET /api/cadence/:id
```

#### Update Cadence Record
```
PUT /api/cadence/:id
```

#### Delete Cadence Record
```
DELETE /api/cadence/:id
```

#### Get Statistics Summary
```
GET /api/cadence/stats/summary
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalRecords": 10,
    "averageCadence": 175.3,
    "totalSteps": 15750,
    "totalDuration": 3600.5
  }
}
```

## Project Structure

```
backend/
├── server.js              # Main server file
├── routes/
│   └── cadence.js          # Cadence API routes
├── data/
│   └── cadence.json        # JSON data storage
├── package.json            # Dependencies and scripts
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## Data Storage

The API uses a simple JSON file (`data/cadence.json`) for data persistence. Each cadence record contains:

- **id**: Unique identifier (UUID)
- **timestamp**: When the tracking session started
- **averageCadence**: Average steps per minute during the session
- **totalSteps**: Total steps taken during the session
- **duration**: Session duration in seconds
- **createdAt**: When the record was created in the API

## Error Handling

The API includes comprehensive error handling:

- **400 Bad Request**: Missing required fields
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server errors

All errors return JSON with success: false and an error message.

## Security

- **Helmet.js**: Security headers
- **CORS**: Cross-origin resource sharing
- **Input Validation**: Required field validation
- **Error Handling**: Proper error responses without exposing internals

## Development

### Scripts

- `npm start`: Start production server
- `npm run dev`: Start development server with auto-restart
- `npm test`: Run tests (not implemented yet)

### Environment Variables

The server uses the following environment variables:

- `PORT`: Server port (default: 3000)

### Adding New Endpoints

1. Add new routes to `routes/cadence.js`
2. Follow the existing pattern for error handling
3. Update this README with new endpoint documentation

## Testing

Test the API using curl or a tool like Postman:

```bash
# Health check
curl http://localhost:3000/health

# Get all cadence records
curl http://localhost:3000/api/cadence

# Create new record
curl -X POST http://localhost:3000/api/cadence \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2024-01-01T12:00:00.000Z",
    "averageCadence": 180.5,
    "totalSteps": 1250,
    "duration": 600.5
  }'
```

## Future Enhancements

- Database integration (PostgreSQL, MongoDB)
- User authentication and authorization
- Data validation with schema validation
- Rate limiting
- Caching
- Unit and integration tests
- Docker containerization
- Environment-specific configurations 