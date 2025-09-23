// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QLMStudio",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "QLMStudio",
            targets: ["QLMStudio"]
        )
    ],
    targets: [
        .executableTarget(
            name: "QLMStudio"
        )
    ]
)
