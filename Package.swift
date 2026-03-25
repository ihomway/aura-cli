// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Package.swift
//  aura-cli
//
//  Created by PuerGozi
//

import PackageDescription

let package = Package(
    name: "aura-cli",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/rensbreur/SwiftTUI", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "aura-cli",
            dependencies: ["SwiftTUI"],
            path: "Sources/aura-cli"
        )
    ]
)
