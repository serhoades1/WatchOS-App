import Combine
import CoreMotion
import Foundation

public class CadenceManager: ObservableObject {
    private let pedometer = CMPedometer()
    private var timer: Timer?
    private var startTime: Date?
    private var cadenceReadings: [Double] = []

    @Published public var currentCadence: Double = 0.0
    @Published public var averageCadence: Double = 0.0
    @Published public var totalSteps: Int = 0
    @Published public var isTracking: Bool = false

    public init() {
        // Initialize the cadence manager
    }

    public func requestPermissions() {
        // Check if step counting is available
        if CMPedometer.isStepCountingAvailable() {
            print("Step counting is available")
        } else {
            print("Step counting not available")
        }

        // Check if cadence data is available (only on iOS/watchOS)
        #if !os(macOS)
            if CMPedometer.isCadenceAvailable() {
                print("Native cadence data available")
            } else {
                print("Cadence data not available - will calculate from step count")
            }
        #endif
    }

    public func startTracking() {
        guard !isTracking else { return }

        startTime = Date()
        isTracking = true
        cadenceReadings.removeAll()
        totalSteps = 0
        currentCadence = 0.0

        // Start pedometer updates
        pedometer.startUpdates(from: Date()) { [weak self] (data, error) in
            guard let self = self else { return }

            if let error = error {
                print("Pedometer error: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            DispatchQueue.main.async {
                self.totalSteps = data.numberOfSteps.intValue
                self.calculateCadence()
            }
        }

        // Start timer for regular updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Timer callback for regular updates
        }
    }

    public func stopTracking() {
        guard isTracking else { return }

        isTracking = false
        pedometer.stopUpdates()
        timer?.invalidate()
        timer = nil

        calculateAverageCadence()
        saveCadenceData()
    }

    private func calculateCadence() {
        guard let startTime = startTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)
        guard elapsedTime > 0 else { return }

        // Calculate steps per minute
        let stepsPerSecond = Double(totalSteps) / elapsedTime
        let stepsPerMinute = stepsPerSecond * 60.0

        currentCadence = stepsPerMinute
        cadenceReadings.append(currentCadence)

        // Keep only last 10 readings for smoother average
        if cadenceReadings.count > 10 {
            cadenceReadings.removeFirst()
        }
    }

    private func calculateAverageCadence() {
        guard !cadenceReadings.isEmpty else { return }

        let validReadings = cadenceReadings.filter { $0 > 0 }
        guard !validReadings.isEmpty else { return }

        averageCadence = validReadings.reduce(0, +) / Double(validReadings.count)
    }

    private func saveCadenceData() {
        let sessionData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "averageCadence": averageCadence,
            "totalSteps": totalSteps,
            "duration": startTime.map { Date().timeIntervalSince($0) } ?? 0,
        ]

        print("Cadence session completed:")
        print("Average Cadence: \(averageCadence)")
        print("Total Steps: \(totalSteps)")
        print("Duration: \(startTime.map { Date().timeIntervalSince($0) } ?? 0)")

        // Save to backend
        saveCadenceToBackend(sessionData)
    }

    private func saveCadenceToBackend(_ data: [String: Any]) {
        guard let url = URL(string: "http://localhost:3000/api/cadence") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error saving cadence data: \(error)")
                } else {
                    print("Cadence data saved successfully")
                }
            }.resume()
        } catch {
            print("Error encoding cadence data: \(error)")
        }
    }
}
