# ``XCTHealthKit``

<!--
                  
This source file is part of the XCTHealthKit open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

XCTHealthKit is an XCTest-based framework to test the creation of HealthKit samples using the Apple Health App on the iPhone simulator.

You can use XCTHealthKit in your UI tests.
The framework has the following functionalities:

### Add Mock Data Using the Apple Health App

Use the `XCTestCase`'s `exitAppAndOpenHealth(_: HealthAppDataType) throws` function passing in an `HealthAppDataType` instance to add mock data using the Apple Health app:
```swift
import XCTest
import XCTHealthKit


class HealthKitUITests: XCTestCase {
    func testAddMockDataUsingTheAppleHealthApp() throws {
        try exitAppAndOpenHealth(.electrocardiograms)
        try exitAppAndOpenHealth(.steps)
        try exitAppAndOpenHealth(.pushes)
        try exitAppAndOpenHealth(.restingHeartRate)
        try exitAppAndOpenHealth(.activeEnergy)
    }
}
```

### Handle the HealthKit Authorization Sheet

You can use the `XCUIApplication`'s `handleHealthKitAuthorization() throws` function to handle the HealthKit authorization sheet:
```swift
import XCTest
import XCTHealthKit


class HealthKitUITests: XCTestCase {
    func testHandleTheHealthKitAuthorizationSheet() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Request HealthKit Authorization"].tap()
        try app.handleHealthKitAuthorization()
    }
}
```

### Inspect the System Under Test if it Contains HKTypeIdentifier Static Text Elements

You can use the `XCUIApplication`'s `numberOfHKTypeIdentifiers() throws` function to inspect the system under test if it contains HKTypeIdentifier static text elements:
```swift
import XCTest
import XCTHealthKit


class HealthKitUITests: XCTestCase {
    func testInspectTheSystemUnderTestIfItContainsHKTypeIdentifierStaticTextElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertEqual(
            HealthAppDataType.numberOfHKTypeIdentifiers(in: app),
            [
                "HKQuantityTypeIdentifierActiveEnergyBurned": 2,
                "HKQuantityTypeIdentifierRestingHeartRate": 1,
                "HKDataTypeIdentifierElectrocardiogram": 3,
                "HKQuantityTypeIdentifierStepCount": 1
            ]
        )
    }
}
```
