// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Downpour",
  products: [
      .library(name: "Downpour", targets: ["Downpour"])
  ],
  dependencies: [
      .package(url: "https://github.com/Ponyboy47/TrailBlazer.git", from: "0.15.0"),
      .package(url: "https://github.com/Ponyboy47/SwiftShell.git", from: "4.2.0")
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
