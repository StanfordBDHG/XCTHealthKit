<!--
                  
This source file is part of the XCTHealthKit open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

# XCTHealthKit

[![Build and Test](https://github.com/StanfordBDHG/XCTHealthKit/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordBDHG/XCTHealthKit/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/XCTHealthKit/branch/main/graph/badge.svg?token=boAhFgMIOp)](https://codecov.io/gh/StanfordBDHG/XCTHealthKit)

XCTHealthKit is an XCTest-based framework to test the creation of HealthKit samples using the Apple Health App on the iPhone simulator.

## How To Use XCTHealthKit

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

## Installation

XCTHealthKit can be added tp your Xcode project or Swift Package using the [Swift Package Manager](https://github.com/apple/swift-package-manager).

For an Xcode project, follow the instructions on [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).
You can take a look at the [Swift Package Manager documentation about defining dependencies for your Swift Package](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#defining-dependencies).

## License
This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordBDHG/XCTHealthKit/tree/main/LICENSES) for more information.


## Contributors
This project is developed as part of the Stanford Byers Center for Biodesign at Stanford University.
See [CONTRIBUTORS.md](https://github.com/StanfordBDHG/XCTHealthKit/tree/main/CONTRIBUTORS.md) for a full list of all XCTHealthKit contributors.

![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-light.png#gh-light-mode-only)
![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-dark.png#gh-dark-mode-only)
