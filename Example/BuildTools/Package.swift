// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BuildTools",
            targets: ["BuildTools"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/ruwatana/swifixture.git",
            revision: "f78418cb05233bcc386f90c41c067de0491b4490")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BuildTools",
            dependencies: [
                .product(name: "swifixture", package: "Swifixture")
            ]
        )
    ]
)
