//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCTestCase {
    /// Exits the system under test and opens the Apple Health app to show the page defined by the passed in ``HealthAppDataType`` instance.
    /// - Parameter healthDataType: The ``HealthAppDataType`` indicating the page in the Apple Health app that should be opened.
    public func exitAppAndOpenHealth(_ healthDataType: HealthAppDataType) throws {
        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            guard alert.buttons["Allow"].exists else {
                XCTFail("Failed not dismiss alert: \(alert.staticTexts.allElementsBoundByIndex)")
                return false
            }
            
            alert.buttons["Allow"].tap()
            return true
        }
        
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        healthApp.activate()
        
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 2) {
            handleWelcomeToHealth()
        }
        
        guard healthApp.tabBars["Tab Bar"].buttons["Browse"].waitForExistence(timeout: 3) else {
            XCTFail("Failed to identify the Add Data Button: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        healthApp.tabBars["Tab Bar"].buttons["Browse"].tap()
        healthApp.tabBars["Tab Bar"].buttons["Browse"].tap()
        XCTAssert(healthApp.navigationBars.staticTexts["Browse"].waitForExistence(timeout: 10))
        
        try healthDataType.navigateToElement()
        
        guard healthApp.navigationBars.firstMatch.buttons["Add Data"].waitForExistence(timeout: 3) else {
            XCTFail("Failed to identify the Add Data Button: \(healthApp.buttons.allElementsBoundByIndex)")
            XCTFail("Failed to identify the Add Data Button: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        healthApp.navigationBars.firstMatch.buttons["Add Data"].tap()
        
        healthDataType.addData()
        
        guard healthApp.navigationBars.firstMatch.buttons["Add"].waitForExistence(timeout: 3) else {
            XCTFail("Failed to identify the Add button: \(healthApp.buttons.allElementsBoundByIndex)")
            XCTFail("Failed to identify the Add button: \(healthApp.staticTexts.allElementsBoundByIndex)")
            throw XCTestError(.failureWhileWaiting)
        }
        
        healthApp.navigationBars.firstMatch.buttons["Add"].tap()
    }
    
    
    private func handleWelcomeToHealth(alreadyRecursive: Bool = false) {
        let healthApp = XCUIApplication(bundleIdentifier: "com.apple.Health")
        
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 2) {
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 2))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 2))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.tables.buttons["Next"].waitForExistence(timeout: 2))
            healthApp.tables.buttons["Next"].tap()
            
            // Sometimes the HealthApp fails to advance to the next step here.
            // Go back and try again.
            if !healthApp.staticTexts["Continue"].waitForExistence(timeout: 45) {
                // Go one step back.
                healthApp.navigationBars["WDBuddyFlowUserInfoView"].buttons["Back"].tap()
                
                XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 2))
                healthApp.staticTexts["Continue"].tap()
                
                // Check if the Next button exists or of the view is still in a loading process.
                if healthApp.tables.buttons["Next"].waitForExistence(timeout: 2) {
                    healthApp.tables.buttons["Next"].tap()
                }
                
                // Continue button still doesn't exist, go for terminating the app.
                if !healthApp.staticTexts["Continue"].waitForExistence(timeout: 45) {
                    if alreadyRecursive {
                        XCTFail("Even the recursive process did fail. Terminate the process.")
                    }
                    
                    healthApp.terminate()
                    healthApp.activate()
                    handleWelcomeToHealth(alreadyRecursive: true)
                    return
                }
            }
            
            healthApp.staticTexts["Continue"].tap()
        }
    }
}
