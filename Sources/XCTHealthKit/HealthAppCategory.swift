//
// This source file is part of the Stanford XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import XCTest


/// A category in the health app
public enum HealthAppCategory: String, Hashable, Sendable {
    case activity = "Activity"
    case bodyMeasurements = "Body Measurements"
    case cycleTracking = "Cycle Tracking"
    case hearing = "Hearing"
    case heart = "Heart"
    case medications = "Medications"
    case mentalWellbeing = "Mental Wellbeing"
    case mobility = "Mobility"
    case nutrition = "Nutrition"
    case respiratory = "Respiratory"
    case sleep = "Sleep"
    case symptoms = "Symptoms"
    case vitals = "Vitals"
    case otherData = "Other Data"
    
    
    /// The category's english-language display title in the Health app's "Browse" tab.
    public var healthAppDisplayTitle: String {
        rawValue
    }
    
    
    /// Navigates in the health app to the category, and selects it.
    @MainActor
    public func navigateToPage(in healthApp: XCUIApplication = .healthApp) throws {
        try healthApp.assertIsHealthApp()
        
        let categoryTitle = self.rawValue
        
        // Dismiss any sheets that may still be open
        if healthApp.navigationBars.buttons["Cancel"].exists {
            healthApp.navigationBars.buttons["Cancel"].tap()
        }
        
        try healthApp.goToBrowseTab()
        
        // Find category:
        let categoryStaticTextPredicate = NSPredicate(format: "label CONTAINS[cd] %@", categoryTitle)
        let categoryStaticText = healthApp.staticTexts.element(matching: categoryStaticTextPredicate).firstMatch
        
        if categoryStaticText.waitForExistence(timeout: 30), !categoryStaticText.isHittable {
            healthApp.swipeUp()
            
            if !categoryStaticText.isHittable {
                healthApp.swipeUp()
            }
        }
        
        categoryStaticText.tap()
        
        // Retry ...
        if !healthApp.navigationBars.staticTexts[categoryTitle].waitForExistence(timeout: 20) {
            categoryStaticText.tap()
        }
        
        guard healthApp.navigationBars.staticTexts[categoryTitle].waitForExistence(timeout: 20) else {
            logger.notice("Failed to find category: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
    }
}
