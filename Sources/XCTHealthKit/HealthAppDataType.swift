//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import OSLog
import XCTest


/// The ``HealthAppDataType`` defines a specific part of the Apple Health app and its corresponding `HKSample` type that is used in a UI-based test.
///
/// Use the ``HealthAppDataType/navigateToElement()`` and ``HealthAppDataType/addData()`` methods to navigate to the respective part of the
/// Apple Health app and enter a new mock data element that can, e.g., be observed in the system under test.
public enum HealthAppDataType: String, CaseIterable {
    /// The active energy subpage of the Apple Health app. Corresponds to `HKQuantityType(.activeEnergyBurned)` samples.
    case activeEnergy = "Active Energy"
    /// The resting heart rate subpage of the Apple Health app. Corresponds to `HKQuantityType(.restingHeartRate)` samples.
    case restingHeartRate = "Resting Heart Rate"
    /// The electrocardiograms subpage of the Apple Health app. Corresponds to `HKQuantityType.electrocardiogramType()` samples.
    case electrocardiograms = "Electrocardiograms (ECG)"
    /// The steps subpage of the Apple Health app. Corresponds to `HKQuantityType(.stepCount)` samples.
    case steps = "Steps"
    /// The pushes subpage of the Apple Health app. Corresponds to `HKQuantityType(.pushCount)` samples.
    case pushes = "Pushes"
    
    
    /// The string value of the corresponding sample type.
    public var hkTypeName: String {
        switch self {
        case .activeEnergy:
            return HKQuantityType(.activeEnergyBurned).identifier
        case .restingHeartRate:
            return HKQuantityType(.restingHeartRate).identifier
        case .electrocardiograms:
            return HKQuantityType.electrocardiogramType().identifier
        case .steps:
            return HKQuantityType(.stepCount).identifier
        case .pushes:
            return HKQuantityType(.pushCount).identifier
        }
    }
    
    /// The category in the Apple Health app
    public var hkCategory: String {
        switch self {
        case .activeEnergy, .steps, .pushes:
            return "Activity"
        case .restingHeartRate, .electrocardiograms:
            return "Heart"
        }
    }
    
    
    /// Navigates to the element in the Apple Health app
    public func navigateToElement() throws {
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        
        if healthApp.navigationBars["Browse"].buttons["Cancel"].exists {
            healthApp.navigationBars["Browse"].buttons["Cancel"].tap()
        }
        try findCategoryAndElement(in: healthApp)
    }
    
    func findCategoryAndElement(in healthApp: XCUIApplication) throws {
        // Find category:
        let categoryStaticTextPredicate = NSPredicate(format: "label CONTAINS[cd] %@", hkCategory)
        let categoryStaticText = healthApp.staticTexts.element(matching: categoryStaticTextPredicate).firstMatch
        
        if categoryStaticText.waitForExistence(timeout: 30), !categoryStaticText.isHittable {
            healthApp.swipeUp()
            
            if !categoryStaticText.isHittable {
                healthApp.swipeUp()
            }
        }
        
        categoryStaticText.tap()
        
        // Retry ...
        if !healthApp.navigationBars.staticTexts[hkCategory].waitForExistence(timeout: 20) {
            categoryStaticText.tap()
        }
        
        guard healthApp.navigationBars.staticTexts[hkCategory].waitForExistence(timeout: 20) else {
            os_log("Failed to find category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        
        // Find element:
        let elementStaticTextPredicate = NSPredicate(format: "label CONTAINS[cd] %@", rawValue)
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
            
            os_log("Failed to find element in category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        elementStaticText.tap()
    }
    
    /// Enters a new mock value in the Apple Health app
    public func addData() {
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        
        switch self {
        case .activeEnergy:
            XCTAssert(healthApp.tables.textFields["cal"].waitForExistence(timeout: 2))
            healthApp.tables.textFields["cal"].tap()
            healthApp.tables.textFields["cal"].typeText("42")
        case .restingHeartRate:
            XCTAssert(healthApp.tables.textFields["BPM"].waitForExistence(timeout: 2))
            healthApp.tables.textFields["BPM"].tap()
            healthApp.tables.textFields["BPM"].typeText("80")
        case .electrocardiograms:
            XCTAssert(healthApp.tables.staticTexts["High Heart Rate"].waitForExistence(timeout: 2))
            healthApp.tables.staticTexts["High Heart Rate"].tap()
        case .steps:
            XCTAssert(healthApp.tables.textFields["Steps"].waitForExistence(timeout: 2))
            healthApp.tables.textFields["Steps"].tap()
            healthApp.tables.textFields["Steps"].typeText("42")
        case .pushes:
            XCTAssert(healthApp.tables.textFields["Pushes"].waitForExistence(timeout: 2))
            healthApp.tables.textFields["Pushes"].tap()
            healthApp.tables.textFields["Pushes"].typeText("42")
        }
    }
}
