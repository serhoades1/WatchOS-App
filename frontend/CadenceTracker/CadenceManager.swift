import Foundation
import CoreMotion
import Combine

class CadenceManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentCadence: Double = 0.0
    @Published var averageCadence: Double = 0.0
    @Published var totalSteps: Int = 0
    @Published var isTracking: Bool = false
    
    private var cadenceReadings: [Double] = []
    private var startTime: Date?
    private var timer: Timer?
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        // Configure motion manager
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.deviceMotionUpdateInterval = 0.1
    }
    
    func requestPermissions() {
        // Check if step counting is available
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting not available")
            return
        }
        
        // Check if device motion is available (for additional motion data)
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }
        
        // Check if cadence data is available (iOS 9.0+)
        if #available(iOS 9.0, *) {
            if CMPedometer.isCadenceAvailable() {
                print("Native cadence data available")
            } else {
                print("Cadence data not available - will calculate from step count")
                // We can still proceed without native cadence support
            }
        }
        
        print("Motion permissions and capabilities verified")
    }
    
    func startTracking() {
        guard !isTracking else { return }
        
        startTime = Date()
        isTracking = true
        cadenceReadings.removeAll()
        
        // Start pedometer updates
        pedometer.startUpdates(from: Date()) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            DispatchQueue.main.async {
                self.totalSteps = data.numberOfSteps.intValue
                self.calculateCadence()
            }
        }
        
        // Start timer for regular updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCadence()
        }
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        isTracking = false
        pedometer.stopUpdates()
        timer?.invalidate()
        timer = nil
        
        // Calculate final averages
        calculateAverageCadence()
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
    
    private func updateCadence() {
        // This method can be used for additional real-time updates
        // For now, cadence is calculated in the pedometer callback
    }
    
    private func calculateAverageCadence() {
        guard !cadenceReadings.isEmpty else { return }
        
        let validReadings = cadenceReadings.filter { $0 > 0 }
        guard !validReadings.isEmpty else { return }
        
        averageCadence = validReadings.reduce(0, +) / Double(validReadings.count)
    }
    
    func saveCadenceData() {
        let cadenceData = CadenceData(
            timestamp: Date(),
            averageCadence: averageCadence,
            totalSteps: totalSteps,
            duration: startTime.map { Date().timeIntervalSince($0) } ?? 0
        )
        
        // Save to backend (implement API call)
        saveCadenceToBackend(cadenceData)
    }
    
    private func saveCadenceToBackend(_ data: CadenceData) {
        // Implementation for saving to backend API
        guard let url = URL(string: "http://localhost:3000/api/cadence") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(data)
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