//
// This source file is part of the XCTHealthKit open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import XCTest


extension XCTestCase {
    /// Launches the Health app and adds the specified sample to the database.
    @MainActor
    public func launchAndAddSample(
        healthApp: XCUIApplication = .healthApp, // swiftlint:disable:this function_default_parameter_at_end
        _ sample: NewHealthSampleInput
    ) throws {
        try launchAndAddSamples(healthApp: healthApp, CollectionOfOne(sample))
    }
    
    /// Launches the Health app and adds the specified samples to the database.
    @MainActor
    public func launchAndAddSamples(
        healthApp: XCUIApplication = .healthApp, // swiftlint:disable:this function_default_parameter_at_end
        _ samples: some Collection<NewHealthSampleInput>
    ) throws {
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
        
        let samplesByCategory = Dictionary(grouping: samples, by: \.sampleType.category)
        for (category, samples) in samplesByCategory {
            try category.navigateToPage(in: healthApp)
            let samplesBySampleType = Dictionary(grouping: samples, by: \.sampleType)
            for (sampleType, samples) in samplesBySampleType {
                try sampleType.navigateToPage(in: healthApp, assumeAlreadyInCategory: true)
                for sample in samples {
                    try sample.create(in: healthApp)
                }
            }
        }
    }
}


extension XCUIApplication {
    /// Attempts to navigate the Health app to the "search" (nee "Browse") tab.
    ///
    /// - Note: This function expects that no modals or sheets are currently presented.
    @MainActor
    public func goToBrowseTab() throws {
        if XCTestCase.isIOS26OrGreater {
            try assertIsHealthApp()
            if self.navigationBars["Search"].exists {
                return
            }
            let searchTabBarButton = self.tabBars.buttons["Search"]
            guard searchTabBarButton.waitForExistence(timeout: 2) && searchTabBarButton.isHittable else {
                if dismissAccountSheetIfNecessary() {
                    try goToBrowseTab()
                    return
                } else {
                    throw XCTHealthKitError("Unable to find 'Search' tab bar item")
                }
            }
            searchTabBarButton.tap() // select the tab
            if searchTabBarButton.isHittable {
                searchTabBarButton.tap() // go back to the tab's root VC, if necessary
            }
        } else {
            let browseTabBarButton = self.tabBars["Tab Bar"].buttons["Browse"]
            if !browseTabBarButton.waitForExistence(timeout: 2) && browseTabBarButton.isHittable {
                throw XCTHealthKitError("Unable to find 'Browse' tab bar item")
            }
            browseTabBarButton.tap() // select the tab
            browseTabBarButton.tap() // go back to the tab's root VC, if necessary
        }
    }
    
    /// - returns: `true` if the account sheet was dismissed, otherwise false.
    @MainActor
    func dismissAccountSheetIfNecessary() -> Bool {
        let doneButton = self.navigationBars["HealthExperienceUI.ProfileView"].buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
            XCTAssert(doneButton.waitForNonExistence(timeout: 2))
            return true
        } else {
            return false
        }
    }
}
