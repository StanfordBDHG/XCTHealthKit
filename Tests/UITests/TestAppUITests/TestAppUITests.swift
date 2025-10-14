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


class TestAppUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        installHealthAppNotificationsAlertMonitor()
    }
    
    @MainActor
    func testXCTHealthKitAsk() {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        app.buttons["Request HealthKit Authorization"].tap()
        app.handleHealthKitAuthorization()
    }
    
    @MainActor
    func testXCTHealthRecordsAsk() throws {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        app.buttons["Request HealthKit Health Records Authorization"].tap()
        handleHealthRecordsAuthorization()
    }
    
    @MainActor
    func testXCTHealthKitAddSamples1() throws {
        let healthApp = XCUIApplication.healthApp
        try launchAndAddSample(.electrocardiogram())
        try launchAndAddSample(.steps())
        healthApp.terminate()
        try launchAndAddSample(.pushes())
        try launchAndAddSample(.restingHeartRate())
        healthApp.terminate()
        try launchAndAddSample(.activeEnergy())
    }
    
    @MainActor
    func testXCTHealthKitAddSamples2() throws {
        let healthApp = XCUIApplication.healthApp
        try launchAndAddSamples([.electrocardiogram(), .steps()])
        healthApp.terminate()
        try launchAndAddSamples([.pushes(), .restingHeartRate()])
        healthApp.terminate()
        try launchAndAddSample(.activeEnergy())
    }
    
    @MainActor
    func testSampleEntryWithDateAndTime() throws {
        try launchAndAddSample(.steps(
            value: 52,
            date: DateComponents(year: 2025, month: 01, day: 19, hour: 14, minute: 42)
        ))
    }
    
    @MainActor
    func testEnterCharacteristics() throws {
        try launchHealthAppAndEnterCharacteristics(.init(
            bloodType: .aNegative,
            dateOfBirth: .init(year: 2022, month: 10, day: 11),
            biologicalSex: .female,
            skinType: .I,
            wheelchairUse: .no
        ))
    }
}
