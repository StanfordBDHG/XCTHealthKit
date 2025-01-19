//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import XCTest


@available(
    *,
     deprecated,
     message: "This API is supplanted by the functionality offered as part of the HealthAppSampleType and its related functions."
)
public enum HealthAppDataType: CaseIterable {
    case activeEnergy
    case restingHeartRate
    case electrocardiograms
    case steps
    case pushes
    
    public var mappedSampleType: HealthAppSampleType {
        switch self {
        case .activeEnergy: .activeEnergy
        case .restingHeartRate: .restingHeartRate
        case .electrocardiograms: .electrocardiograms
        case .steps: .steps
        case .pushes: .pushes
        }
    }
}


extension XCTestCase {
    /// Exits the system under test and opens the Apple Health app to show the page defined by the passed in ``HealthAppDataType`` instance.
    /// - Parameter healthDataType: The ``HealthAppDataType`` indicating the page in the Apple Health app that should be opened.
    @available(
        *,
         deprecated,
         renamed: "launchHealthAppAndAddSomeSamples(_:)",
         message: "Use launchHealthAppAndAddSomeSamples(_:) instead, which allows more control over the samples being added."
    )
    @MainActor
    public func exitAppAndOpenHealth(_ healthDataType: HealthAppDataType) throws {
        let sample: NewHealthSampleInput
        switch healthDataType {
        case .activeEnergy:
            sample = .init(sampleType: .activeEnergy, enterSampleValueHandler: .enterSimpleNumericValue(
                52,
                inTextField: NSPredicate(format: "label LIKE[cd] %@ OR label LIKE[cd] %@", "cal", "kcal")
            ))
        case .restingHeartRate:
            sample = .init(sampleType: .restingHeartRate, enterSampleValueHandler: .enterSimpleNumericValue(80))
        case .electrocardiograms:
            sample = .init(sampleType: .electrocardiograms, enterSampleValueHandler: .custom { _, app in
                XCTAssert(app.tables.staticTexts["High Heart Rate"].firstMatch.waitForExistence(timeout: 2))
                app.tables.staticTexts["High Heart Rate"].firstMatch.tap()
            })
        case .steps:
            sample = .init(sampleType: .steps, enterSampleValueHandler: .enterSimpleNumericValue(75))
        case .pushes:
            sample = .init(sampleType: .pushes, enterSampleValueHandler: .enterSimpleNumericValue(85))
        }
        try launchHealthAppAndAddSomeSamples([sample])
    }
}
