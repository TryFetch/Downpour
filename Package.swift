// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Downpour",
  platforms: [.macOS(.v10_14)],
  products: [
      .library(name: "Downpour", targets: ["Downpour"])
  ],
  dependencies: [
      .package(url: "https://github.com/Ponyboy47/TrailBlazer.git", from: "0.16.0"),
      .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0")
  ],
  targets: [
      .target(
          name: "Downpour",
          dependencies: ["TrailBlazer", "SwiftShell"],
          path: "Sources"
          ),
      .testTarget(
          name: "DownpourTests",
          dependencies: ["Downpour"],
          path: "Tests/DownpourTests"
          )
  ]
)
