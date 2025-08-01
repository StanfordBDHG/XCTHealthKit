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
    public static var healthApp: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.Health")
    }
}


extension XCUIApplication {
    /// Returns the `XCUIApplication`'s bundle identifier.
    nonisolated public var bundleIdentifier: String {
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
    nonisolated public var isHealthApp: Bool {
        self.bundleIdentifier == "com.apple.Health"
    }
    
    /// Asserts that this is the Health app.
    nonisolated public func assertIsHealthApp() throws {
        guard isHealthApp else {
            throw XCTHealthKitError("App \(bundleIdentifier) is not the Health app!")
        }
    }
}


extension XCUIApplication {
    /// Detects and dismisses the HealthKit Authorization sheet.
    ///
    /// - parameter timeout: how long the function should wait for the sheet to appear.
    /// - parameter requireSheetToAppear: Whether the function should require the sheet to appear, i.e. whether it should fail if no Health permissions sheet is presented within the `timeout`.
    public func handleHealthKitAuthorization(
        timeout: TimeInterval = 20,
        requireSheetToAppear: Bool = false
    ) {
        if self.navigationBars["Health Access"].waitForExistence(timeout: timeout) {
            self.tables.staticTexts["Turn On All"].tap()
            self.navigationBars["Health Access"].buttons["Allow"].tap()
        } else if requireSheetToAppear {
            XCTFail("No Health permissions sheet appeared within the timeout (\(timeout) sec)")
        }
    }
}
