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
        let sheet = self.navigationBars["Health Access"]
        guard sheet.waitForExistence(timeout: timeout) else {
            if requireSheetToAppear {
                XCTFail("No Health permissions sheet appeared within the timeout (\(timeout) sec)")
            }
            return
        }
        // The navigation bar renders before the list of data types is populated, so the row has to be waited for.
        // Before iOS 27 it is the "Turn On All" text in a table; from iOS 27 it is a cell of its own, labelled with
        // the number of topics, so we look for it by its identifier.
        let turnOnAll = self.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == 'UIA.Health.AuthSheet.AllCategoryButton' OR label == 'Turn On All'"))
            .firstMatch
        XCTAssert(turnOnAll.wait(for: \.isHittable, toEqual: true, timeout: 30), "The Health permissions sheet did not finish loading")
        turnOnAll.tap()
        // "Allow" is a navigation bar button before iOS 27; from iOS 27 it is a "Continue" button at the end of the list,
        // which only enters the element tree once it has been scrolled to.
        let allow = self.buttons
            .matching(NSPredicate(format: "identifier == 'UIA.Health.Allow.Button' OR label == 'Allow'"))
            .firstMatch
        for _ in 0..<12 where !(allow.exists && allow.isHittable) {
            self.swipeUp()
        }
        XCTAssert(allow.wait(for: \.isHittable, toEqual: true, timeout: 10), "'Allow' never became hittable")
        allow.tap()
        // From iOS 27, a second page asks how much history to share, with "Allow" disabled until a choice is made.
        // We share all of it, so that tests see every sample they added.
        let allRecorded = self.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH 'All Recorded Data'"))
            .firstMatch
        if allRecorded.waitForExistence(timeout: 5) {
            allRecorded.tap()
            let confirm = self.buttons["Allow"]
            XCTAssert(confirm.wait(for: \.isHittable, toEqual: true, timeout: 10), "'Allow' never became hittable after choosing the history")
            confirm.tap()
        }
        if !sheet.waitForNonExistence(timeout: 10) {
            // The tap can land before the toggles commit, which leaves 'Allow' disabled and the tap a no-op.
            allow.tap()
            XCTAssert(sheet.waitForNonExistence(timeout: 10), "The Health permissions sheet did not dismiss")
        }
    }
}
