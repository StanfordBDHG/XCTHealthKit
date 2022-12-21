//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


/// <#Description#>
public enum HealthAppDataType: String, CaseIterable {
    /// <#Description#>
    case activeEnergy = "Active Energy"
    /// <#Description#>
    case restingHeartRate = "Resting Heart Rate"
    /// <#Description#>
    case electrocardiograms = "Electrocardiograms (ECG)"
    /// <#Description#>
    case steps = "Steps"
    /// <#Description#>
    case pushes = "Pushes"
    
    
    /// <#Description#>
    public var hkTypeName: String {
        switch self {
        case .activeEnergy:
            return "HKQuantityTypeIdentifierActiveEnergyBurned"
        case .restingHeartRate:
            return "HKQuantityTypeIdentifierRestingHeartRate"
        case .electrocardiograms:
            return "HKDataTypeIdentifierElectrocardiogram"
        case .steps:
            return "HKQuantityTypeIdentifierStepCount"
        case .pushes:
            return "HKQuantityTypeIdentifierPushCount"
        }
    }
    
    /// <#Description#>
    public var hkCategory: String {
        switch self {
        case .activeEnergy, .steps, .pushes:
            return "Activity"
        case .restingHeartRate, .electrocardiograms:
            return "Heart"
        }
    }
    
    
    /// <#Description#>
    /// - Parameter healthApp: <#healthApp description#>
    /// - Returns: <#description#>
    public static func numberOfHKTypeNames(in healthApp: XCUIApplication) -> [String: Int] {
        var observations: [String: Int] = [:]
        for healthDataType in allCases {
            let numberOfHKTypeNames = healthApp.staticTexts.allElementsBoundByIndex
                .filter {
                    $0.label.contains(healthDataType.hkTypeName)
                }
                .count
            observations[healthDataType.hkTypeName] = numberOfHKTypeNames
        }
        return observations
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - healthApp: <#healthApp description#>
    ///   - type: <#type description#>
    /// - Returns: <#description#>
    public static func numberOfHKTypeNames(in healthApp: XCUIApplication, ofType type: HealthAppDataType) -> Int {
        healthApp.staticTexts.allElementsBoundByIndex.filter { $0.label.contains(type.hkTypeName) } .count
    }
    
    
    /// <#Description#>
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
        
        if categoryStaticText.waitForExistence(timeout: 20) {
            categoryStaticText.tap()
        } else {
            XCTFail("Failed to find category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        // Find element:
        let elementStaticTextPredicate = NSPredicate(format: "label CONTAINS[cd] %@", rawValue)
        var elementStaticText = healthApp.staticTexts.element(matching: elementStaticTextPredicate).firstMatch
        
        guard elementStaticText.waitForExistence(timeout: 10) else {
            healthApp.firstMatch.swipeUp(velocity: .slow)
            elementStaticText = healthApp.buttons.element(matching: elementStaticTextPredicate).firstMatch
            if elementStaticText.waitForExistence(timeout: 10) {
                elementStaticText.tap()
                return
            }
            
            healthApp.firstMatch.swipeDown(velocity: .slow)
            elementStaticText = healthApp.buttons.element(matching: elementStaticTextPredicate).firstMatch
            if elementStaticText.waitForExistence(timeout: 10) {
                elementStaticText.tap()
                return
            }
            
            XCTFail("Failed to find element in category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        elementStaticText.tap()
    }
    
    /// <#Description#>
    public func addData() {
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        
        switch self {
        case .activeEnergy:
            healthApp.tables.textFields["cal"].tap()
            healthApp.tables.textFields["cal"].typeText("42")
        case .restingHeartRate:
            healthApp.tables.textFields["BPM"].tap()
            healthApp.tables.textFields["BPM"].typeText("80")
        case .electrocardiograms:
            healthApp.tables.staticTexts["High Heart Rate"].tap()
        case .steps:
            healthApp.tables.textFields["Steps"].tap()
            healthApp.tables.textFields["Steps"].typeText("42")
        case .pushes:
            healthApp.tables.textFields["Pushes"].tap()
            healthApp.tables.textFields["Pushes"].typeText("42")
        }
    }
}
