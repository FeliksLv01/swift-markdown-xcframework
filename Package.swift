// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftMarkdownBinary",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Markdown", targets: ["Markdown"])
    ],
    targets: [
        .binaryTarget(
            name: "Markdown",
            url: "https://github.com/FeliksLv01/swift-markdown-xcframework/releases/download/swift-markdown-0.8.0-patch.1/Markdown.xcframework.zip",
            checksum: "6cced53923415a6a73acbae503bb521021db7174fd5b5c102e2e26a58bd891bb"
        )
    ]
)
