// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "QLMStudio",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .macOSApplication(
            name: "QLM Studio",
            targets: ["QLMStudio"],
            bundleIdentifier: "com.abhijeetanand.qlmstudio",
            displayVersion: "0.1.0",
            bundleVersion: "1",
            iconAssetName: nil,
            accentColorAssetName: nil
        )
    ],
    targets: [
        .executableTarget(
            name: "QLMStudio"
        )
    ]
)
