//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


struct XCTHealthKitError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}


extension XCUIApplication {
    /// The Apple Health app
    public static func healthApp() -> XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.Health")
    }
}


extension XCUIApplication {
    /// Returns the `XCUIApplication`'s bundle identifier.
    public var bundleIdentifier: String {
        let desc = self.description
        for prefix in ["Application '", "Target Application '"] {
            guard desc.hasPrefix(prefix) && desc.hasSuffix("'") else {
                continue
            }
            return String(desc.dropFirst(prefix.count).dropLast())
        }
        return ""
    }
    
    /// Checks whether the app is in fact apple's Health app.
    public var isHealthApp: Bool {
        self.bundleIdentifier == "com.apple.Health"
    }
    
    /// Asserts that this is the Health app.
    public func assertIsHealthApp() throws {
        guard isHealthApp else {
            throw XCTHealthKitError("App \(bundleIdentifier) is not the Health app!")
        }
    }
    
    /// Detects and dismisses the HealthKit Authorization sheet. Fails if the sheet is not displayed.
    public func handleHealthKitAuthorization() throws {
        if !self.navigationBars["Health Access"].waitForExistence(timeout: 10) {
            logger.notice("The HealthKit View did not load after 10 seconds ... give it a second try with a timeout of 20 seconds.")
        }
        if self.navigationBars["Health Access"].waitForExistence(timeout: 20) {
            self.tables.staticTexts["Turn On All"].tap()
            self.navigationBars["Health Access"].buttons["Allow"].tap()
        }
    }
}
