// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reeeed",
    platforms: [.iOS("15.0"), .macOS("12.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Reeeed",
            targets: ["Reeeed"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cezheng/Fuzi", from: "3.1.3"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Reeeed",
            dependencies: ["Fuzi", "SwiftSoup"],
            resources: [.process("JS")]),
        .testTarget(
            name: "ReeeedTests",
            dependencies: ["Reeeed"]),
    ]
)
