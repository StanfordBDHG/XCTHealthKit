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
            Button("Request HealthKit Health Records Authorization") {
                Task {
                    try await requestHealthRecordsAccess()
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
        
        private func requestHealthRecordsAccess() async throws {
            guard HKHealthStore.isHealthDataAvailable() else {
                return
            }
            let healthStore = HKHealthStore()
            
            var sampleTypes: Set<HKClinicalType> = Set([
                HKObjectType.clinicalType(forIdentifier: .allergyRecord),
                HKObjectType.clinicalType(forIdentifier: .coverageRecord),
                HKObjectType.clinicalType(forIdentifier: .conditionRecord),
                HKObjectType.clinicalType(forIdentifier: .labResultRecord),
                HKObjectType.clinicalType(forIdentifier: .medicationRecord),
                HKObjectType.clinicalType(forIdentifier: .immunizationRecord),
                HKObjectType.clinicalType(forIdentifier: .procedureRecord),
                HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)
            ].compactMap { $0 })
            
            if #available(iOS 16.4, *), let clinicalNoteRecord = HKObjectType.clinicalType(forIdentifier: .clinicalNoteRecord) {
                sampleTypes.insert(clinicalNoteRecord)
            }
            
            try await healthStore.requestAuthorization(toShare: [], read: sampleTypes)
        }
}
