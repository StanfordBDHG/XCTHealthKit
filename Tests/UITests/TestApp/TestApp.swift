//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import SwiftUI


@main
struct UITestsApp: App {
    var body: some Scene {
        WindowGroup {
            content
        }
    }
    
    @ViewBuilder private var content: some View {
        Form {
            Button("Request HealthKit Authorization") {
                Task {
                    try await requestAccess()
                }
            }
        }
    }
    
    private func requestAccess() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        let healthStore = HKHealthStore()
        let sampleTypes: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.walkingStepLength),
            HKQuantityType(.walkingSpeed),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.distanceDownhillSnowSports),
            HKQuantityType(.walkingAsymmetryPercentage),
            HKQuantityType(.stairAscentSpeed)
        ]
        try await healthStore.requestAuthorization(toShare: [], read: sampleTypes)
    }
}
