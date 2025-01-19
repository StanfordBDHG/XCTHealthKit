//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
import XCTest


/// A Sample type within the Health app.
public struct HealthAppSampleType: Hashable {
    public let category: HealthAppCategory
    public let sampleType: HKSampleType
    public let healthAppDisplayTitle: String
    
    /// Creates a new sample type, with the specified fields
    public init(category: HealthAppCategory, sampleType: HKSampleType, healthAppDisplayTitle: String) {
        self.category = category
        self.sampleType = sampleType
        self.healthAppDisplayTitle = healthAppDisplayTitle
    }
}


// MARK: Some Well-Known Sample Types

extension HealthAppSampleType {
    /// The active energy subpage of the Apple Health app. Corresponds to `HKQuantityType(.activeEnergyBurned)` samples.
    public static let activeEnergy = Self(
        category: .activity,
        sampleType: HKQuantityType(.activeEnergyBurned),
        healthAppDisplayTitle: "Active Energy"
    )
    /// The resting heart rate subpage of the Apple Health app. Corresponds to `HKQuantityType(.restingHeartRate)` samples.
    public static let restingHeartRate = Self(
        category: .heart,
        sampleType: HKQuantityType(.restingHeartRate),
        healthAppDisplayTitle: "Resting Heart Rate"
    )
    /// The electrocardiograms subpage of the Apple Health app. Corresponds to `HKQuantityType.electrocardiogramType()` samples.
    public static let electrocardiograms = Self(
        category: .heart,
        sampleType: .electrocardiogramType(),
        healthAppDisplayTitle: "Electrocardiograms (ECG)"
    )
    /// The steps subpage of the Apple Health app. Corresponds to `HKQuantityType(.stepCount)` samples.
    public static let steps = Self(
        category: .activity,
        sampleType: HKQuantityType(.stepCount),
        healthAppDisplayTitle: "Steps"
    )
    /// The pushes subpage of the Apple Health app. Corresponds to `HKQuantityType(.pushCount)` samples.
    public static let pushes = Self(
        category: .activity,
        sampleType: HKQuantityType(.pushCount),
        healthAppDisplayTitle: "Pushes"
    )
    
    /// All currently well-known sample types.
    public static let all: [Self] = [
        .activeEnergy, .restingHeartRate, .electrocardiograms, .steps, .pushes
    ]
}


// MARK: XCTest Navigation

extension HealthAppSampleType {
    /// Navigates the Health app to the sample type's page.
    public func navigateToPage(in healthApp: XCUIApplication, assumeAlreadyInCategory: Bool) throws {
        if !assumeAlreadyInCategory {
            try category.navigateToPage(in: healthApp)
        }
        
        let elementStaticTextPredicate = NSPredicate(format: "label CONTAINS[cd] %@", healthAppDisplayTitle)
        let elementStaticText = healthApp.staticTexts.element(matching: elementStaticTextPredicate).firstMatch
        
        guard elementStaticText.waitForExistence(timeout: 30), elementStaticText.isHittable else {
            healthApp.swipeUp()
            if elementStaticText.waitForExistence(timeout: 10), elementStaticText.isHittable {
                elementStaticText.tap()
                return
            }
            
            healthApp.swipeUp()
            if elementStaticText.waitForExistence(timeout: 10), elementStaticText.isHittable {
                elementStaticText.tap()
                return
            }
            
            logger.notice("Failed to find element in category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        elementStaticText.tap()
    }
}
