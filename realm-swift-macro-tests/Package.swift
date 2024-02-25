// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "realm-swift-macro-tests",
    platforms: [.macOS(.v14)],
    products: [],
    dependencies: [
        // Parent directory
        .package(path: ".."),

        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.2"),
//        .package(path: "../realm-swift"), // local 'realm-swift'
        .package(url: "https://github.com/rjchatfield/realm-swift.git", branch: "rob/macros-realm-changes"),
    ],
    targets: [
        .testTarget(
            name: "RealmSwiftMacroTests",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "RealmMacro", package: "realm-swift-macro"),
                .product(name: "_RealmMacroCore", package: "realm-swift-macro"),

                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
