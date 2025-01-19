//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import XCTest


extension XCTestCase {
    /// Launches the Health app and adds the specified samples to the database.
    @MainActor
    public func launchHealthAppAndAddSomeSamples(_ samples: [NewHealthSampleInput]) throws {
        let healthApp = XCUIApplication.healthApp()
        // Note that we intentionally use launch here, rather than activate.
        // This will ensure that we have a fresh instance of the app, and we won't have to deal with any sheets
        // or other modals potentially being presented.
        // There might still be some state restoration going on (eg: the Health app will sometimes navigate to the last-used
        // page w/in one of the tabs), but that's easy to handle.
        healthApp.launch()
        
        // Handle onboarding, if necessary
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 3) {
            handleOnboarding()
        }
        
        let browseTabBarButton = healthApp.tabBars["Tab Bar"].buttons["Browse"]
        
        if !browseTabBarButton.waitForExistence(timeout: 2) && browseTabBarButton.isHittable {
            throw XCTHealthKitError("Unable to find 'Browse' tab bar item")
        }
        
        browseTabBarButton.tap() // select the tab
        browseTabBarButton.tap() // go back to the tab's root VC, if necessary
        
        let samplesByCategory = Dictionary(grouping: samples, by: \.sampleType.category)
        for (category, samples) in samplesByCategory {
            try category.navigateToPage(in: healthApp)
            let samplesBySampleType = Dictionary(grouping: samples, by: \.sampleType)
            for (sampleType, samples) in samplesBySampleType {
                try sampleType.navigateToPage(in: healthApp, assumeAlreadyInCategory: true)
                for sample in samples {
                    try sample.create(in: healthApp)
                }
            }
        }
    }
    
    
    private func handleOnboarding(alreadyRecursive: Bool = false) {
        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            guard alert.buttons["Allow"].exists else {
                XCTFail("Failed not dismiss alert: \(alert.staticTexts.allElementsBoundByIndex)")
                return false
            }
            
            alert.buttons["Allow"].tap()
            return true
        }
        
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 5) {
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.tables.buttons["Next"].waitForExistence(timeout: 5))
            healthApp.tables.buttons["Next"].tap()
            
            // Sometimes the HealthApp fails to advance to the next step here.
            // Go back and try again.
            if !healthApp.staticTexts["Continue"].waitForExistence(timeout: 60) {
                // Go one step back.
                healthApp.navigationBars["WDBuddyFlowUserInfoView"].buttons["Back"].tap()
                
                XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
                healthApp.staticTexts["Continue"].tap()
                
                // Check if the Next button exists or of the view is still in a loading process.
                if healthApp.tables.buttons["Next"].waitForExistence(timeout: 5) {
                    healthApp.tables.buttons["Next"].tap()
                }
                
                // Continue button still doesn't exist, go for terminating the app.
                if !healthApp.staticTexts["Continue"].waitForExistence(timeout: 60) {
                    if alreadyRecursive {
                        logger.notice("Even the recursive process did fail. Terminate the process.")
                    }
                    
                    healthApp.terminate()
                    healthApp.activate()
                    handleOnboarding(alreadyRecursive: true)
                    return
                }
            }
            
            // Try to turn off the Health Notifications Trends Switch:
            let trendsSwitch = healthApp.switches.firstMatch
            if trendsSwitch.waitForExistence(timeout: 5) && trendsSwitch.isHittable {
                trendsSwitch.tap()
            }
            
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
            healthApp.staticTexts["Continue"].tap()
        }
    }
}
