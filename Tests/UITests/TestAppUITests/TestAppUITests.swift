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
    func testXCTHealthKitAsk() throws {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        app.buttons["Request HealthKit Authorization"].tap()
        try app.handleHealthKitAuthorization()
    }
    
    @MainActor
    func testXCTHealthKitAddSamples1() throws {
        let healthApp = XCUIApplication.healthApp
        try launchAndAddSample(healthApp: healthApp, .electrocardiogram())
        try launchAndAddSample(healthApp: healthApp, .steps())
        healthApp.terminate()
        try launchAndAddSample(healthApp: healthApp, .pushes())
        try launchAndAddSample(healthApp: healthApp, .restingHeartRate())
        healthApp.terminate()
        try launchAndAddSample(healthApp: healthApp, .activeEnergy())
    }
    
    
    @MainActor
    func testXCTHealthKitAddSamples2() throws {
        let healthApp = XCUIApplication.healthApp
        try launchAndAddSamples(healthApp: healthApp, [.electrocardiogram(), .steps()])
        healthApp.terminate()
        try launchAndAddSamples(healthApp: healthApp, [.pushes(), .restingHeartRate()])
        healthApp.terminate()
        try launchAndAddSample(healthApp: healthApp, .activeEnergy())
    }
    
    
    @MainActor
    func testSampleEntryWithDateAndTime() throws {
        try launchAndAddSample(healthApp: .healthApp, .steps(
            value: 52,
            date: DateComponents(year: 2025, month: 01, day: 19, hour: 14, minute: 42)
        ))
    }
}
