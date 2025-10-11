//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import XCTest

/// Sample health record data in the health app
public enum HealthAppHealthRecordAccount: String, CaseIterable {
    case sampleA = "A", sampleB = "B", sampleC = "C"
    
    var institutionName: String {
        "Sample Institution \(self.rawValue)"
    }
    
    var locationName: String {
        "Sample Location \(self.rawValue)"
    }
}

/// Represents all supported HealthKit clinical record types.
///
/// Each case maps to a corresponding `HKClinicalTypeIdentifier`.
/// The `clinicalType` property returns the matching `HKClinicalType` if available on the current iOS version.
/// The `description` property matches the display name shown in the HealthKit authorization sheet.
public enum HealthRecordType: CaseIterable {
    case allergyRecord
    case clinicalNoteRecord
    case vitalSignRecord
    case conditionRecord
    case immunizationRecord
    case coverageRecord
    case labResultRecord
    case medicationRecord
    case procedureRecord
    
    public var description: String {
        switch self {
        case .allergyRecord: return "Allergies"
        case .clinicalNoteRecord: return "Clinical Notes"
        case .vitalSignRecord: return "Clinical Vitals"
        case .conditionRecord: return "Conditions"
        case .immunizationRecord: return "Immunizations"
        case .coverageRecord: return "Insurance"
        case .labResultRecord: return "Lab Results"
        case .medicationRecord: return "Medications"
        case .procedureRecord: return "Procedures"
        }
    }
    
    public var clinicalType: HKClinicalType? {
        switch self {
        case .allergyRecord:
            return HKObjectType.clinicalType(forIdentifier: .allergyRecord)
        case .clinicalNoteRecord:
            if #available(iOS 16.4, *) {
                return HKObjectType.clinicalType(forIdentifier: .clinicalNoteRecord)
            } else {
                return nil
            }
        case .vitalSignRecord:
            return HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)
        case .conditionRecord:
            return HKObjectType.clinicalType(forIdentifier: .conditionRecord)
        case .immunizationRecord:
            return HKObjectType.clinicalType(forIdentifier: .immunizationRecord)
        case .coverageRecord:
            return HKObjectType.clinicalType(forIdentifier: .coverageRecord)
        case .labResultRecord:
            return HKObjectType.clinicalType(forIdentifier: .labResultRecord)
        case .medicationRecord:
            return HKObjectType.clinicalType(forIdentifier: .medicationRecord)
        case .procedureRecord:
            return HKObjectType.clinicalType(forIdentifier: .procedureRecord)
        }
    }
}

extension XCUIApplication {
    /// Handles and dismisses the Health Records authorization flow in the Health app during UI tests.
    ///
    /// This method navigates through the Health Records permission sheet, enables all provided
    /// clinical record types for sharing, and completes the authorization process.
    ///
    /// - Parameters:
    ///   - healthRecordTypes: The record types to enable for sharing. Defaults to all supported types.
    ///   - automaticallyShareUpdates: Whether to enable automatic sharing when prompted. Defaults to `true`.
    ///
    /// - Note:
    ///   Before calling this method, ensure that `configureHealthRecordAccount` has been run to add
    ///   a Health Records account, and that the simulator or device region is set to **United States**, **Canada**, or **United Kingdom**,
    ///   as Health Records are only available in those regions.
    public func handleHealthRecordsAuthorization(
        healthRecordTypes: [HealthRecordType] = HealthRecordType.allCases,
        automaticallyShareUpdates: Bool = true
    ) {
        XCTAssertTrue(navigationBars["HealthUI.ClinicalAuthorizationAccountsIntroView"].waitForExistence(timeout: 10))
        
        for _ in 1...3 {
            XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 5))
            buttons["Next"].tap()
        }
        
        HealthRecordType.allCases.forEach {
            if !switches[$0.description].waitForExistence(timeout: 5) {
                swipeDown()
                XCTAssertTrue(switches[$0.description].waitForExistence(timeout: 5))
            }
            switches[$0.description].tap()
        }
        
        XCTAssertTrue(buttons["Share"].waitForExistence(timeout: 5))
        buttons["Share"].tap()
        
        if automaticallyShareUpdates {
            XCTAssertTrue(staticTexts["Automatically Share"].waitForExistence(timeout: 5))
            staticTexts["Automatically Share"].tap()
        }
        
        XCTAssertTrue(buttons["Done"].waitForExistence(timeout: 5))
        buttons["Done"].tap()
    }
}

extension XCTestCase {
    /// Configures a Health Records account in the Health app for UI testing.
    ///
    /// If the specified account is already connected, the method detects this and exits early.
    ///
    /// - Parameters:
    ///   - healthApp: The `XCUIApplication` instance representing the Health app.
    ///   - account: The `HealthAppHealthRecordAccount` to connect.
    ///
    /// - Note:
    ///   Before calling this method, ensure that the simulator or device region is set to **United States**, **Canada**, or **United Kingdom**,
    ///   as Health Records are only available in those regions.
    @MainActor
    public func configureHealthRecordAccount(healthApp: XCUIApplication, account: HealthAppHealthRecordAccount) throws {
        try healthApp.assertIsHealthApp()
        // Note that we intentionally use launch here, rather than activate.
        // This will ensure that we have a fresh instance of the app, and we won't have to deal with any sheets
        // or other modals potentially being presented.
        // There might still be some state restoration going on (eg: the Health app will sometimes navigate to the last-used
        // page w/in one of the tabs), but that's easy to handle.
        healthApp.launch()
        
        // Handle onboarding, if necessary
        handleHealthAppOnboardingIfNecessary(healthApp)
        
        try healthApp.goToBrowseTab()
        
        for _ in 0...3 {
            healthApp.swipeUp()
        }
        
        if healthApp.staticTexts[account.locationName].waitForExistence(timeout: 5) {
            return
        }
        
        XCTAssertTrue(healthApp.staticTexts["Add Account"].waitForExistence(timeout: 5))
        healthApp.staticTexts["Add Account"].tap()
        XCTAssertTrue(healthApp.staticTexts[account.institutionName].waitForExistence(timeout: 5))
        healthApp.staticTexts[account.institutionName].tap()
        XCTAssertTrue(healthApp.staticTexts["Connect Account"].waitForExistence(timeout: 5))
        healthApp.staticTexts["Connect Account"].tap()
        XCTAssertTrue(healthApp.staticTexts["Done"].waitForExistence(timeout: 5))
        healthApp.staticTexts["Done"].tap()
    }
}
