// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SpatialMCPServer",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    // Swift SDK for Model Context Protocol
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.12.0"),
    // A logging API for Swift
    .package(url: "https://github.com/apple/swift-log", from: "1.10.1"),
  ],
  targets: [
    .executableTarget(
      name: "SpatialMCPServer",
      dependencies: [
        .product(name: "MCP", package: "swift-sdk"),
        .product(name: "Logging", package: "swift-log"),
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)
