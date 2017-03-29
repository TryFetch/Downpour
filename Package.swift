import PackageDescription

var dependencies: [Package.Dependency] = [.Package(url: "https://github.com/Ponyboy47/PathKit.git", majorVersion: 0, minor: 8)]

#if os(Linux)
dependencies.append(.Package(url: "https://github.com/vdka/JSON.git", majorVersion: 0, minor: 16))
#endif

let package = Package(
  name: "Downpour",
  dependencies: dependencies,
  exclude: [
      "Tests"
  ]
)
