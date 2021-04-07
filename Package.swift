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
        .package(url: "https://github.com/pumperknickle/AwesomeDictionary.git", from: "0.1.1"),
        .package(url: "https://github.com/pumperknickle/Bedrock.git", from: "0.2.2"),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
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
