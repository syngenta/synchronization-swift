// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Synchronization-swift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Synchronization-swift",
            targets: ["Synchronization-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.13.0")
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Synchronization-swift",
            dependencies: ["PromiseKit"]
        ),
//        .testTarget(
//            name: "Synchronization-swiftTests",
//            dependencies: ["Synchronization-swift"]),
    ]
)
