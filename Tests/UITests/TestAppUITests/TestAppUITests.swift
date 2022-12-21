//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTHealthKit


class TestAppUITests: XCTestCase {
    func testXCTHealthKitAsk() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Request HealthKit Authorization"].tap()
        try app.handleHealthKitAuthorization()
    }
    
    func testXCTHealthKitExitAppAndOpenHealth() throws {
        try exitAppAndOpenHealth(.electrocardiograms)
        try exitAppAndOpenHealth(.steps)
        try exitAppAndOpenHealth(.pushes)
        try exitAppAndOpenHealth(.restingHeartRate)
        try exitAppAndOpenHealth(.activeEnergy)
    }
    
    
    func testXCTHealthNumberOfHKTypeNames() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertEqual(
            HealthAppDataType.numberOfHKTypeNames(in: app),
            [
                "HKQuantityTypeIdentifierActiveEnergyBurned": 2,
                "HKQuantityTypeIdentifierRestingHeartRate": 1,
                "HKDataTypeIdentifierElectrocardiogram": 3,
                "HKQuantityTypeIdentifierStepCount": 1,
                "HKQuantityTypeIdentifierPushCount": 0
            ]
        )
    }
}
