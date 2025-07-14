import Combine
import CoreMotion
import SwiftUI

struct ContentView: View {
    @StateObject private var cadenceManager = CadenceManager()
    @State private var isTracking = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Cadence Tracker")
                .font(.headline)
                .foregroundColor(.primary)

            // Current cadence display
            VStack {
                Text("\(Int(cadenceManager.currentCadence))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("steps/min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)

            // Average cadence
            if cadenceManager.averageCadence > 0 {
                VStack {
                    Text("Average: \(Int(cadenceManager.averageCadence))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Start/Stop button
            Button(action: {
                if isTracking {
                    cadenceManager.stopTracking()
                } else {
                    cadenceManager.startTracking()
                }
                isTracking.toggle()
            }) {
                HStack {
                    Image(systemName: isTracking ? "stop.fill" : "play.fill")
                    Text(isTracking ? "Stop" : "Start")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(isTracking ? Color.red : Color.green)
                .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())

            // Status indicator
            HStack {
                Circle()
                    .fill(isTracking ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)

                Text(isTracking ? "Tracking" : "Stopped")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Step count
            Text("Steps: \(cadenceManager.totalSteps)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            cadenceManager.requestPermissions()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
