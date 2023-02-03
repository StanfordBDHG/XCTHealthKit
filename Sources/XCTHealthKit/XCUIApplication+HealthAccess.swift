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
        }
        if self.navigationBars["Health Access"].waitForExistence(timeout: 20) {
            self.tables.staticTexts["Turn On All"].tap()
            self.navigationBars["Health Access"].buttons["Allow"].tap()
        }
    }

    /// Collects the number of occurences of HealthKit type identifier in the current user interface of the system unter test.
    /// - Returns: Returns a dictionairy containing the HealthKit type identifier as a key and the number of occurences as the value.
    public func numberOfHKTypeIdentifiers() -> [String: Int] {
        var observations: [String: Int] = [:]
        for healthDataType in HealthAppDataType.allCases {
            let numberOfHKTypeNames = self.staticTexts.allElementsBoundByIndex
                .filter {
                    $0.label.contains(healthDataType.hkTypeName)
                }
                .count
            if numberOfHKTypeNames > 0 {
                observations[healthDataType.hkTypeName] = numberOfHKTypeNames
            }
        }
        return observations
    }
    
    /// Collects the number of occurences of a specific HealthKit type identifier in the current user interface of the system unter test.
    /// - Parameters:
    ///   - type: The type that should be identified.
    /// - Returns: Returns the number of occurences of a specific HealthKit type identifier in the current user interface of the system unter test.
    public func numberOfHKTypeNames(ofType type: HealthAppDataType) -> Int {
        self.staticTexts.allElementsBoundByIndex.filter { $0.label.contains(type.hkTypeName) } .count
    }
}
