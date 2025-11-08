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

extension XCTestCase {
    /// Handles and dismisses the Health Records authorization flow in the Health app during UI tests.
    ///
    /// This method navigates through the Health Records permission sheet, enables all provided
    /// clinical record types for sharing, and completes the authorization process.
    ///
    /// - Parameters:
    ///   - systemUnderTest: The app under test (`XCUIApplication`) that initiates the Health Records authorization.
    ///                      Defaults to a new `XCUIApplication` instance.
    ///   - healthApp: The `XCUIApplication` instance representing the Health app. Defaults to `.healthApp`.
    ///   - account: The `HealthAppHealthRecordAccount` to use when authorizing access. Defaults to `.sampleA`.
    ///   - healthRecordTypes: The clinical record types to enable for sharing. Defaults to all available types.
    ///   - automaticallyShareUpdates: A Boolean value indicating whether to enable automatic sharing of updates
    ///                                when prompted. Defaults to `true`.
    ///   - timeout: How long the function will wait for the initial sheet to appear.
    ///   - requireSheetToAppear: Whether the function should require the sheet to appear, i.e. whether it should fail if no Health permissions sheet is presented within the `timeout`.
    ///
    /// - Note:
    ///   Before calling this method, ensure  that the simulator or device region is set to **United States**, **Canada**, or **United Kingdom**, as Health Records are only available in those regions.
    @MainActor
    public func handleHealthRecordsAuthorization( // swiftlint:disable:this function_body_length
        systemUnderTest: XCUIApplication = XCUIApplication(),
        healthApp: XCUIApplication = .healthApp,
        accounts: [HealthAppHealthRecordAccount] = HealthAppHealthRecordAccount.allCases,
        healthRecordTypes: [HealthRecordType] = HealthRecordType.allCases,
        automaticallyShareUpdates: Bool = true,
        timeout: TimeInterval = 10,
        requireSheetToAppear: Bool = false
    ) {
        guard systemUnderTest.navigationBars["HealthUI.ClinicalAuthorizationAccountsIntroView"].waitForExistence(timeout: timeout) else {
            if !requireSheetToAppear {
                // the sheet did not show up, and we're fine with that.
                return
            } else {
                XCTFail("No Health Records permissions sheet appeared within the timeout (\(timeout) sec)")
                return
            }
        }
        
        XCTAssertTrue(systemUnderTest.buttons["Next"].waitForExistence(timeout: 2))
        systemUnderTest.buttons["Next"].tap()
        
        for account in accounts {
            guard !systemUnderTest.staticTexts[account.locationName].waitForExistence(timeout: 2) else {
                continue
            }
            XCTAssertTrue(systemUnderTest.staticTexts["Add Account"].waitForExistence(timeout: 2))
            systemUnderTest.staticTexts["Add Account"].tap()
            
            handleHealthAppOnboardingIfNecessary(healthApp)
            
            // if we're adding multiple accounts, and are going back and forth between the app being tested and the Health app,
            // only the first time an account is added will the "welcome to clinical records" sheet actually be shown...
            if case let button = healthApp.buttons["UIA.Health.SuggestedAction.SetUpClinicalRecords.PrimaryButton"],
               button.waitForExistence(timeout: 5),
               button.isHittable {
                button.tap()
            }
            
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let allowButton = springboard.buttons["Allow Once"]
            if allowButton.waitForExistence(timeout: 5) {
                allowButton.tap()
            }
            
            XCTAssertTrue(healthApp.staticTexts[account.institutionName].waitForExistence(timeout: 2))
            healthApp.staticTexts[account.institutionName].tap()
            
            XCTAssertTrue(healthApp.staticTexts["Connect Account"].waitForExistence(timeout: 2))
            healthApp.staticTexts["Connect Account"].tap()
            
            XCTAssertTrue(healthApp.staticTexts["Done"].waitForExistence(timeout: 2))
            healthApp.staticTexts["Done"].tap()
        }
        
        for _ in 0..<2 {
            XCTAssertTrue(systemUnderTest.buttons["Next"].waitForExistence(timeout: 2))
            systemUnderTest.buttons["Next"].tap()
        }
        
        HealthRecordType.allCases.forEach {
            if !systemUnderTest.switches[$0.description].waitForExistence(timeout: 2) {
                systemUnderTest.swipeDown()
                XCTAssertTrue(systemUnderTest.switches[$0.description].waitForExistence(timeout: 2))
            }
            systemUnderTest.switches[$0.description].tap()
        }
        
        XCTAssertTrue(systemUnderTest.buttons["Share"].waitForExistence(timeout: 2))
        systemUnderTest.buttons["Share"].tap()
        
        if automaticallyShareUpdates {
            XCTAssertTrue(systemUnderTest.staticTexts["Automatically Share"].waitForExistence(timeout: 2))
            systemUnderTest.staticTexts["Automatically Share"].tap()
        }
        
        XCTAssertTrue(systemUnderTest.buttons["Done"].waitForExistence(timeout: 2))
        systemUnderTest.buttons["Done"].tap()
    }
}
