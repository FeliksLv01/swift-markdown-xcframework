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
            checksum: "9eda1d78bad380856aa966d68e4cae89a461c619e3e0e2266cb2effc4b77d736"
        )
    ]
)
