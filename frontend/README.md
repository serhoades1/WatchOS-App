# Cadence Tracker - WatchOS App

A simple WatchOS app that tracks your running/walking cadence using the Apple Watch's built-in sensors.

## Features

- **Real-time Cadence Tracking**: Displays your current steps per minute
- **Average Cadence**: Shows your average cadence during a tracking session
- **Step Counter**: Tracks total steps taken during the session
- **Simple UI**: Clean, easy-to-read interface optimized for Apple Watch
- **Backend Integration**: Saves tracking data to a REST API

## Requirements

- **Apple Watch**: Series 4 or later
- **watchOS**: 9.0 or later
- **Xcode**: 15.0 or later for development

## Project Structure

```
frontend/
├── CadenceTracker.xcodeproj/     # Xcode project file
├── CadenceTracker/
│   ├── CadenceTrackerApp.swift   # Main app entry point
│   ├── ContentView.swift         # Main UI view
│   ├── CadenceManager.swift      # Core motion tracking logic
│   ├── CadenceData.swift         # Data models
│   ├── Assets.xcassets/          # App icons and colors
│   └── Preview Content/          # SwiftUI preview assets
└── README.md                     # This file
```

## How to Use

1. **Open the App**: Launch "Cadence Tracker" on your Apple Watch
2. **Grant Permissions**: The app will request motion and fitness permissions
3. **Start Tracking**: Tap the "Start" button to begin tracking your cadence
4. **View Real-time Data**: See your current cadence displayed prominently
5. **Stop Tracking**: Tap "Stop" to end the session and save your data

## Key Components

### CadenceManager
- Handles CoreMotion and CMPedometer integration
- Calculates real-time cadence (steps per minute)
- Manages tracking sessions
- Sends data to backend API

### ContentView
- Main SwiftUI interface
- Displays current cadence, average, and tracking status
- Start/Stop button for tracking sessions
- Status indicators and visual feedback

### CadenceData
- Data models for cadence information
- Codable structs for API communication
- Utility methods for formatting data

## Backend Integration

The app connects to a REST API running on `localhost:3000` to save tracking data:

- **POST /api/cadence**: Save new cadence session
- **GET /api/cadence**: Retrieve all sessions
- **GET /api/cadence/stats/summary**: Get summary statistics

## Development

1. Open `CadenceTracker.xcodeproj` in Xcode
2. Set your development team in the project settings
3. Connect your Apple Watch for testing
4. Build and run the app

## Permissions

The app requires the following permissions:
- **Motion & Fitness**: For accessing step data and motion sensors
- **Network**: For sending data to the backend API

## Technical Details

- **Framework**: SwiftUI + Combine
- **Motion Tracking**: CoreMotion (CMPedometer)
- **Data Persistence**: Backend API integration
- **Update Frequency**: Real-time updates every second
- **Target Device**: Apple Watch (watchOS 9.0+)

## Future Enhancements

- Historical data visualization
- Goal setting and achievements
- Heart rate integration
- Workout session integration
- Offline data storage
- Haptic feedback for cadence targets 