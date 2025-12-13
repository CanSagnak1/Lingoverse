// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WordAPI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "WordAPI",
            targets: ["WordAPI"]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "WordAPI",
            dependencies: []
        ),
        .testTarget(
            name: "WordAPITests",
            dependencies: ["WordAPI"],
            resources: [
                // This includes everything under Tests/WordAPITests/Mocks/Stubs into the test bundle.
                .process("Mocks/Stubs")
            ]
        ),
    ]
)
