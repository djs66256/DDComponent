// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DDComponent",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DDComponent",
            targets: ["DDComponent"]
        )
    ],
    targets: [
        .target(
            name: "DDComponent",
            path: "DDComponent/Classes"
        )
    ]
)
