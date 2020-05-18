// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CircleTabBarController",
    platforms: [ .iOS(.v11)],
    products: [
        .library(
            name: "CircleTabBarController",
            targets: ["CircleTabBarController"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CircleTabBarController",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CircleTabBarControllerTests",
            dependencies: ["CircleTabBarController"],
            path: "CircleTabBarControllerTests"),
    ]
)
