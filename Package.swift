// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDFFileLogger",
    platforms: [
      .iOS(.v16),
      .macOS(.v11)
    ],
    products: [
        .library(
            name: "UDFFileLogger",
            targets: ["UDFFileLogger"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/Maks-Jago/SwiftUI-UDF", from: "1.5.0"),
      .package(path: "../UDFMacros"),
      .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "UDFFileLogger",
            dependencies: [
              .product(name: "UDF", package: "SwiftUI-UDF"),
              .product(name: "UDFMacros", package: "UDFMacros"),
              .product(name: "CryptoSwift", package: "CryptoSwift"),
            ]
        ),
        .testTarget(
          name: "UDFFileLoggerTests",
          dependencies: [
            "UDFFileLogger",
          ]
        ),
    ]
)
