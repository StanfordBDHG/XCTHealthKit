//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


class XCTHealthKitTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        installHealthAppNotificationsAlertMonitor()
    }
}
