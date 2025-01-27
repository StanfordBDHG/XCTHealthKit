// swift-tools-version:6.0

//
// This source file is part of the XCTHealthKit open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "XCTHealthKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "XCTHealthKit", targets: ["XCTHealthKit"])
    ],
    targets: [
        .target(
            name: "XCTHealthKit"
        ),
        .testTarget(
            name: "XCTHealthKitTests",
            dependencies: [
                .target(name: "XCTHealthKit")
            ]
        )
    ]
)
