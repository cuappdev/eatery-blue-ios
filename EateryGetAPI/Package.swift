// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EateryGetAPI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "EateryGetAPI", targets: ["EateryGetAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0"))
    ],
    targets: [
        .target(
            name: "EateryGetAPI",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .testTarget(
            name: "EateryGetAPITests",
            dependencies: ["EateryGetAPI"]
        )
    ]
)
