//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Detects and dismisses the HealthKit Authorization sheet. Fails if the sheet is not displayed.
    public func handleHealthKitAuthorization() throws {
        if !self.navigationBars["Health Access"].waitForExistence(timeout: 10) {
            print("The HealthKit View did not load after 10 seconds ... give it a second try with a timeout of 20 seconds.")
            self.buttons["Ask for authorization"].tap()
        }
        if self.navigationBars["Health Access"].waitForExistence(timeout: 20) {
            self.tables.staticTexts["Turn On All"].tap()
            self.navigationBars["Health Access"].buttons["Allow"].tap()
        }
    }
}
