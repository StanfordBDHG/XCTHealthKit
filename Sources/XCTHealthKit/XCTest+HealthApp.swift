//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import XCTest

extension XCTestCase {
    /// Walks through the Health App onboarding flow, if necessary.
    @MainActor
    public func handleHealthAppOnboardingIfNecessary(_ healthApp: XCUIApplication = .healthApp) {
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 3) {
            handleOnboarding(healthApp)
        }
    }
    
    @MainActor
    func handleOnboarding(_ healthApp: XCUIApplication = .healthApp, alreadyRecursive: Bool = false) {
        installHealthAppNotificationsAlertMonitor()
        
        if healthApp.staticTexts["Welcome to Health"].waitForExistence(timeout: 5) {
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.staticTexts["Continue"].waitForExistence(timeout: 5))
            healthApp.staticTexts["Continue"].tap()
            
            XCTAssertTrue(healthApp.buttons["Next"].waitForExistence(timeout: 5))
            healthApp.buttons["Next"].tap()
            
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
                    handleOnboarding(healthApp, alreadyRecursive: true)
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
            
            // Unfortunately it seems like the general notifications dialog triggerd as the function exists
            // which doesn't trigger the IInterruptionMonitor or just exits too early.
            // We manually also check for it's existance:
            let notificationsAllowButton = healthApp.alerts.buttons["Allow"]
            if notificationsAllowButton.waitForExistence(timeout: 1) {
                notificationsAllowButton.tap()
            }
        }
    }
    
    
    /// Installs a UI interruption monitor which will dismiss the "Health would like to send you notifications" alert.
    @discardableResult
    public func installHealthAppNotificationsAlertMonitor() -> any NSObjectProtocol {
        self.addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            MainActor.assumeIsolated {
                guard alert.title.matches(/.Health.Would Like to Send You Notifications/) else {
                    // Not the Health app's Notification request alert.
                    return false
                }
                guard alert.buttons["Allow"].exists else {
                    XCTFail("Failed not dismiss alert: \(alert.staticTexts.allElementsBoundByIndex)")
                    return false
                }
                alert.buttons["Allow"].tap()
                return true
            }
        }
    }
}


extension String {
    func matches(_ regex: some RegexComponent) -> Bool {
        self.firstMatch(of: regex) != nil
    }
}
