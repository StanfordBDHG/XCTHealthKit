<!--
                  
This source file is part of the XCTHealthKit open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

# XCTHealthKit

[![Build and Test](https://github.com/StanfordBDHG/XCTHealthKit/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordBDHG/XCTHealthKit/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/XCTHealthKit/branch/main/graph/badge.svg?token=boAhFgMIOp)](https://codecov.io/gh/StanfordBDHG/XCTHealthKit)
[![DOI](https://zenodo.org/badge/580684238.svg)](https://zenodo.org/badge/latestdoi/580684238)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FXCTHealthKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordBDHG/XCTHealthKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordBDHG%2FXCTHealthKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordBDHG/XCTHealthKit)


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


## Installation

The project can be added to your Xcode project or Swift Package using the [Swift Package Manager](https://github.com/apple/swift-package-manager).

**Xcode:** For an Xcode project, follow the instructions on [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

**Swift Package:** You can follow the [Swift Package Manager documentation about defining dependencies](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#defining-dependencies) to add this project as a dependency to your Swift Package.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordBDHG/XCTHealthKit/tree/main/LICENSES) for more information.


## Contributors

This project is developed as part of the Stanford Byers Center for Biodesign at Stanford University.
See [CONTRIBUTORS.md](https://github.com/StanfordBDHG/XCTHealthKit/tree/main/CONTRIBUTORS.md) for a full list of all XCTHealthKit contributors.

![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-light.png#gh-light-mode-only)
![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-dark.png#gh-dark-mode-only)
