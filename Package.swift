// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AwesomeTrie",
    products: [
        .library(
            name: "AwesomeTrie",
            targets: ["AwesomeTrie"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pumperknickle/AwesomeDictionary.git", from: "0.0.4"),
        .package(url: "https://github.com/pumperknickle/Bedrock.git", from: "0.2.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.2"),
    ],
    targets: [
        .target(
            name: "AwesomeTrie",
            dependencies: ["Bedrock", "AwesomeDictionary"]),
        .testTarget(
            name: "AwesomeTrieTests",
            dependencies: ["AwesomeTrie", "Quick", "Nimble", "Bedrock", "AwesomeDictionary"]),
    ]
)
