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
            List {
                Button("Request HealthKit Authorization") {
                    Task {
                        guard HKHealthStore.isHealthDataAvailable() else {
                            return
                        }
                        
                        let healthStore = HKHealthStore()
                        
                        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                            return
                        }
                        
                        try await healthStore.requestAuthorization(toShare: [], read: [stepType])
                    }
                }
                Text("HKQuantityTypeIdentifierActiveEnergyBurned")
                Text("HKQuantityTypeIdentifierActiveEnergyBurned")
                Text("HKQuantityTypeIdentifierRestingHeartRate")
                Text("HKDataTypeIdentifierElectrocardiogram")
                Text("HKDataTypeIdentifierElectrocardiogram")
                Text("HKDataTypeIdentifierElectrocardiogram")
                Text("HKQuantityTypeIdentifierStepCount")
            }
        }
    }
}
