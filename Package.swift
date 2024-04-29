// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Particlized",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Particlized",
            targets: ["Particlized"]
        ),
    ],
    targets: [
        .target(
            name: "Particlized",
            path: "Sources"
        ),
        .testTarget(
            name: "ParticlizedTests",
            dependencies: ["Particlized"]
        ),
    ]
)
