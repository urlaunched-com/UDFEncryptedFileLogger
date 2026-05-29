// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDFEncryptedFileLogger",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "UDFEncryptedFileLogger",
            targets: ["UDFEncryptedFileLogger"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Maks-Jago/SwiftUI-UDF", from: "1.5.1-rc.6"),
        .package(url: "https://github.com/urlaunched-com/UDFMacros.git", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "UDFEncryptedFileLogger",
            dependencies: [
                .product(name: "UDF", package: "SwiftUI-UDF"),
                .product(name: "UDFMacros", package: "UDFMacros"),
            ]
        ),
        .testTarget(
            name: "UDFEncryptedFileLoggerTests",
            dependencies: [
                "UDFEncryptedFileLogger",
            ]
        ),
    ]
)
