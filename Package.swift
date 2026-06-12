// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUIWindow",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftUIWindow",
            targets: ["SwiftUIWindow"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUIWindow"
        ),
        .testTarget(
            name: "SwiftUIWindowTests",
            dependencies: ["SwiftUIWindow"]
        )
    ]
)
