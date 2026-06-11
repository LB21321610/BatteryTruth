// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BatteryTruth",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BatteryCore",
            targets: ["BatteryCore"]
        ),
        .executable(
            name: "BatteryTruth",
            targets: ["BatteryTruthApp"]
        )
    ],
    targets: [
        .target(
            name: "BatteryCore",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "BatteryTruthApp",
            dependencies: ["BatteryCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("UserNotifications")
            ]
        ),
        .testTarget(
            name: "BatteryCoreTests",
            dependencies: ["BatteryCore"]
        )
    ]
)
