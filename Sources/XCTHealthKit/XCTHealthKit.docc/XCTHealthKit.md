# ``XCTHealthKit``

<!--
                  
This source file is part of the XCTHealthKit open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

XCTHealthKit is an XCTest-based framework to test the creation of HealthKit samples using the Apple Health App on the iPhone simulator.


## How To Use XCTHealthKit

You can use XCTHealthKit in your UI tests. The [API documentation](https://swiftpackageindex.com/StanfordBDHG/XCTHealthKit/documentation) provides a detailed overview of the public interface of XCTHealthKit.

The framework has the following functionalities:


### Add Mock Data Using the Apple Health App

Use the `XCTestCase.launchAndAddSample(healthApp:_:) throws` function passing in an `NewHealthSampleInput` instance to add mock data using the Apple Health app:
```swift
import XCTest
import XCTHealthKit

class HealthKitUITests: XCTestCase {
    func testAddMockData() throws {
        let healthApp = XCUIApplication.healthApp()
        try launchAndAddSample(healthApp: healthApp, .steps(value: 71))
        try launchAndAddSample(healthApp: healthApp, .electrocardiogram())
    }
}
```

Alternatively, the `XCTestCase.launchAndAddSamples(healthApp:_:) throws` function can be used to add multiple samples in a single call:
```swift
import XCTest
import XCTHealthKit

class HealthKitUITests: XCTestCase {
    func testAddMockData() throws {
        let healthApp = XCUIApplication.healthApp()
        try launchAndAddSamples(healthApp: healthApp, [
            .activeEnergy(),
            .electrocardiogram(),
            .pushes(value: 117),
            .restingHeartRate(value: 91),
            .steps()
        ])
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
