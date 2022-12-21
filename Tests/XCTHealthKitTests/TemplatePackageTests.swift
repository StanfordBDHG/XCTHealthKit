//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import XCTHealthKit


final class XCTHealthKitTests: XCTestCase {
    func testXCTHealthKit() throws {
        XCTAssertEqual(HealthAppDataType.activeEnergy.hkTypeName, "HKQuantityTypeIdentifierActiveEnergyBurned")
        XCTAssertEqual(HealthAppDataType.restingHeartRate.hkTypeName, "HKQuantityTypeIdentifierRestingHeartRate")
        XCTAssertEqual(HealthAppDataType.electrocardiograms.hkTypeName, "HKDataTypeIdentifierElectrocardiogram")
        XCTAssertEqual(HealthAppDataType.steps.hkTypeName, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(HealthAppDataType.pushes.hkTypeName, "HKQuantityTypeIdentifierPushCount")
        
        XCTAssertEqual(HealthAppDataType.activeEnergy.hkCategory, "Activity")
        XCTAssertEqual(HealthAppDataType.restingHeartRate.hkCategory, "Heart")
        XCTAssertEqual(HealthAppDataType.electrocardiograms.hkCategory, "Heart")
        XCTAssertEqual(HealthAppDataType.steps.hkCategory, "Activity")
        XCTAssertEqual(HealthAppDataType.pushes.hkCategory, "Activity")
    }
}
