// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MarkdownConsumer",
    platforms: [.iOS(.v15)],
    products: [.library(name: "MarkdownConsumer", targets: ["MarkdownConsumer"])],
    targets: [
        .binaryTarget(name: "Markdown", path: "Markdown.xcframework"),
        .target(name: "MarkdownConsumer", dependencies: ["Markdown"])
    ]
)
