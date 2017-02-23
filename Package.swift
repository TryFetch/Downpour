import PackageDescription


let package = Package(
  name: "Downpour",
  dependencies: [
      .Package(url: "https://github.com/Ponyboy47/PathKit.git", majorVersion: 0, minor: 8)
  ],
  exclude: [
      "Tests"
  ]
)
