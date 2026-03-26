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
        .package(url: "https://github.com/steipete/TauTUI", from: "0.1.5")
    ],
    targets: [
        .executableTarget(
            name: "aura-cli",
            dependencies: [.product(name: "TauTUI", package: "TauTUI")],
            path: "Sources/aura-cli"
        )
    ]
)
