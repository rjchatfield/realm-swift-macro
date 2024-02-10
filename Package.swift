// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RealmMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "RealmMacro",
            targets: ["RealmMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.2"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.1.2"),
//        .package(path: "../realm-swift"), // local 'realm-swift'
        .package(url: "https://github.com/rjchatfield/realm-swift.git", branch: "rob/macros-realm-changes"),
    ],
    targets: [
        // Public API imported by projects
        .target(
            name: "RealmMacro",
            dependencies: [
                "RealmMacroMacros",
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        // Implementation of compiler plugin
        .macro(
            name: "RealmMacroMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        // Tests
        .testTarget(
            name: "RealmMacroTests",
            dependencies: [
                "RealmMacro",
                "RealmMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
    ]
)
