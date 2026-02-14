// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required in order to build this particular package.

import PackageDescription

let package: Package = Package(
    name: "iCollab",

    platforms: [
        // Ensure ScreenCaptureKit and NWConnection are available.
        .macOS(.v13)
    ],

    products: [
        .executable(
            name: "iCollab", 
            targets: ["iCollab"]
        )
    ],

    targets: [
        // Targets are the basic building blocks of a package. They can define a module and/or test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        .executableTarget(
            name: "iCollab",
            path: "Sources",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
    ]
)