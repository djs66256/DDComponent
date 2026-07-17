// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "DDComponent",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "DDComponent",
            targets: ["DDComponent"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .target(
            name: "DDComponent",
            dependencies: ["DDComponentMacrosClient"],
            path: "DDComponent/Classes"
        ),
        .macro(
            name: "DDComponentMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "DDComponentMacros/Sources/DDComponentMacros"
        ),
        .target(
            name: "DDComponentMacrosClient",
            dependencies: ["DDComponentMacros"],
            path: "DDComponentMacros/Sources/DDComponentMacrosClient"
        ),
        .testTarget(
            name: "DDComponentMacrosTests",
            dependencies: [
                "DDComponentMacrosClient",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "DDComponentMacros/Tests/DDComponentMacrosTests"
        ),
    ]
)