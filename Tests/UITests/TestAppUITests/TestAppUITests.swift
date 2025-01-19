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
    func testXCTHealthKitExitAppAndOpenHealth() throws {
        try exitAppAndOpenHealth(.electrocardiograms)
        try exitAppAndOpenHealth(.steps)
        
        let healthApp = XCUIApplication.healthApp()
        healthApp.terminate()
        
        try exitAppAndOpenHealth(.pushes)
        try exitAppAndOpenHealth(.restingHeartRate)
        
        healthApp.terminate()
        
        try exitAppAndOpenHealth(.activeEnergy)
    }
    
    
    @MainActor
    func testSampleEntry() throws {
        try launchHealthAppAndAddSomeSamples([
            NewHealthSampleInput(
                sampleType: .steps,
                enterSampleValueHandler: .enterSimpleNumericValue(52)
            )
        ])
    }
    
    
    @MainActor
    func testSampleEntryWithDateAndTime() throws {
        try launchHealthAppAndAddSomeSamples([
            NewHealthSampleInput(
                sampleType: .steps,
                date: DateComponents(year: 2025, month: 01, day: 19, hour: 14, minute: 42),
                enterSampleValueHandler: .enterSimpleNumericValue(52)
            )
        ])
    }
}
