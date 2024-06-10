// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Synchronization-swift",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Synchronization-swift",
            targets: ["Synchronization-swift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "8.1.2")
    ],
    targets: [
        .target(
            name: "Synchronization-swift",
            dependencies: ["PromiseKit"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)