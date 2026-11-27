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
        if XCTestCase.isIOS27OrGreater {
            try goToBrowseTabIOS27()
        } else if XCTestCase.isIOS26OrGreater {
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
            // Go back to the tab's root VC, if necessary.
            // Note that the tab bar button can disappear once the tab is selected, so we only tap it again if we're not
            // already at the root, and if the button still exists.
            if !self.navigationBars["Search"].waitForExistence(timeout: 2),
               searchTabBarButton.exists && searchTabBarButton.isHittable {
                searchTabBarButton.tap()
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
    
    /// iOS 27 brings back the "Browse" tab (in place of iOS 26's "Search" tab).
    @MainActor
    private func goToBrowseTabIOS27() throws {
        try assertIsHealthApp()
        let browseTabBarButton = self.tabBars.buttons
            .matching(NSPredicate(format: "identifier == 'UIA.Health.Tab.Browse' OR label == 'Browse'"))
            .firstMatch
        // Note: we intentionally don't check `isHittable` here: on iOS 27, the tab bar buttons are reported as not hittable,
        // even though they can be tapped just fine.
        guard browseTabBarButton.waitForExistence(timeout: 10) else {
            throw XCTHealthKitError("Unable to find 'Browse' tab bar item")
        }
        for _ in 0..<3 {
            browseTabBarButton.tap() // select the tab
            browseTabBarButton.tap() // go back to the tab's root VC, if necessary
            if self.navigationBars["Browse"].waitForExistence(timeout: 3) {
                return
            }
            // The Health app restores its previous state when launched, which might e.g. include the profile sheet
            // (potentially with some other page pushed onto it), which would prevent us from switching tabs.
            dismissPresentedSheetIOS27()
        }
        throw XCTHealthKitError("Unable to navigate to the 'Browse' tab")
    }
    
    /// Attempts to dismiss a sheet that might currently be presented in the Health app, on iOS 27.
    @MainActor
    func dismissPresentedSheetIOS27() {
        // pop any pages that have been pushed onto the sheet
        for _ in 0..<5 {
            let backButton = self.navigationBars.buttons["BackButton"].firstMatch
            guard backButton.exists else {
                break
            }
            backButton.tap()
            _ = backButton.waitForNonExistence(timeout: 2)
        }
        let closeButton = self.navigationBars.buttons
            .matching(NSPredicate(format: "identifier IN[c] {'Done', 'close'} OR label IN[c] {'Done', 'close'}"))
            .firstMatch
        if closeButton.exists {
            closeButton.tap()
        } else {
            self.swipeDown(velocity: .fast)
        }
        _ = self.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2)
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
