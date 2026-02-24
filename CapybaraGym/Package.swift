// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CapybaraGym",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CapybaraGym",
            targets: ["CapybaraGym"]
        ),
    ],
    dependencies: [
        // AWS Amplify
        .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.25.0"),
        
        // QR Code Scanner
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.3.0"),
        
        // Image Loading (optional, for async images)
        .package(url: "https://github.com/kean/Nuke", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "CapybaraGym",
            dependencies: [
                // Amplify
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .product(name: "AWSAPIPlugin", package: "amplify-swift"),
                .product(name: "AWSS3StoragePlugin", package: "amplify-swift"),
                
                // QR Code Scanner
                .product(name: "CodeScanner", package: "CodeScanner"),
                
                // Image Loading
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
            ],
            path: "Sources",
            exclude: ["Info.plist"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "CapybaraGymTests",
            dependencies: ["CapybaraGym"]
        ),
    ]
)
