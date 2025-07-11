import Foundation

struct CadenceData: Codable {
    let id: UUID
    let timestamp: Date
    let averageCadence: Double
    let totalSteps: Int
    let duration: TimeInterval
    
    init(timestamp: Date, averageCadence: Double, totalSteps: Int, duration: TimeInterval) {
        self.id = UUID()
        self.timestamp = timestamp
        self.averageCadence = averageCadence
        self.totalSteps = totalSteps
        self.duration = duration
    }
}

extension CadenceData {
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct CadenceSession: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let cadenceReadings: [CadenceReading]
    let averageCadence: Double
    let totalSteps: Int
    
    init(startTime: Date, endTime: Date, cadenceReadings: [CadenceReading]) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.cadenceReadings = cadenceReadings
        self.averageCadence = cadenceReadings.isEmpty ? 0 : cadenceReadings.map { $0.cadence }.reduce(0, +) / Double(cadenceReadings.count)
        self.totalSteps = cadenceReadings.last?.totalSteps ?? 0
    }
}

struct CadenceReading: Codable {
    let timestamp: Date
    let cadence: Double
    let totalSteps: Int
    
    init(timestamp: Date, cadence: Double, totalSteps: Int) {
        self.timestamp = timestamp
        self.cadence = cadence
        self.totalSteps = totalSteps
    }
} 