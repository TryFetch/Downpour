// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Downpour",
  products: [
      .library(name: "Downpour", targets: ["Downpour"])
  ],
  dependencies: [
      .package(url: "https://github.com/Ponyboy47/PathKit.git", .upToNextMinor(from: "0.10.0"))
  ],
  targets: [
      .target(
          name: "Downpour",
          dependencies: ["PathKit"],
          path: "Sources"
          ),
      .testTarget(
          name: "DownpourTests",
          dependencies: ["Downpour"],
          path: "Tests/DownpourTests"
          )
  ]
)
