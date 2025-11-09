//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SwiftUI


struct ContentView: View {
    private let healthStore = HKHealthStore()
    
    @State private var numHealthRecords = 0
    
    var body: some View {
        Form {
            Section("Regular Sample Types") {
                Button("Request HealthKit Authorization") {
                    Task {
                        try await requestAccess()
                    }
                }
            }
            Section("Clinical Record Types") {
                Button("Request HealthKit Health Records Authorization") {
                    Task {
                        try await requestHealthRecordsAccess()
                    }
                }
                LabeledContent("# clinical records", value: numHealthRecords, format: .number)
            }
        }
    }
    
    
    private func requestAccess() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
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
        numHealthRecords = 0
        var sampleTypes: Set<HKClinicalType> = [
            HKClinicalType(.allergyRecord),
            HKClinicalType(.coverageRecord),
            HKClinicalType(.conditionRecord),
            HKClinicalType(.labResultRecord),
            HKClinicalType(.medicationRecord),
            HKClinicalType(.immunizationRecord),
            HKClinicalType(.procedureRecord),
            HKClinicalType(.vitalSignRecord)
        ]
        if #available(iOS 16.4, *) {
            sampleTypes.insert(HKClinicalType(.clinicalNoteRecord))
        }
        try await healthStore.requestAuthorization(toShare: [], read: sampleTypes)
        for sampleType in sampleTypes {
            let descriptor = HKSampleQueryDescriptor(predicates: [HKSamplePredicate.clinicalRecord(type: sampleType)], sortDescriptors: [])
            numHealthRecords += try await descriptor.result(for: healthStore).count
        }
    }
}
