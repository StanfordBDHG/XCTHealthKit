//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTHealthKit


final class AuthorizationTests: XCTHealthKitTestCase {
    @MainActor
    func testAskForPermissions() {
        let app = XCUIApplication()
        app.terminate()
        app.resetAuthorizationStatus(for: .health)
        sleep(for: .seconds(2))
        app.launch()
        app.buttons["Request HealthKit Authorization"].tap()
        app.handleHealthKitAuthorization()
    }
    
    @MainActor
    func testAskForClinicalRecordPermissions() throws {
        let app = XCUIApplication()
        app.terminate()
        app.resetAuthorizationStatus(for: .health)
        sleep(for: .seconds(2))
        app.launch()
        XCTAssert(app.staticTexts["# clinical records, 0"].waitForExistence(timeout: 2))
        app.buttons["Request HealthKit Health Records Authorization"].tap()
        handleHealthRecordsAuthorization()
        XCTAssert(app.staticTexts["# clinical records, 33"].waitForExistence(timeout: 5))
    }
}
