# SwiftMarkdownBinary

An iOS static XCFramework distribution of the official
[`swift-markdown`](https://github.com/swiftlang/swift-markdown) source. The
upstream source remains a pinned git submodule; this repository applies a small
patch during packaging and does not maintain a source fork.

## Patch

The current patch enables `CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE`, so only
`~~text~~` is parsed as strikethrough while `~text~` remains plain text. The
exact upstream tag, commit, and ordered patch list are recorded in
`Patches/manifest.yml`.

## Installation

### Swift Package Manager

Add this repository as a package dependency and link the `Markdown` product.

### CocoaPods

```ruby
pod 'SwiftMarkdownBinary', '0.8.0-patch.1'
```

Both package managers expose the upstream module name:

```swift
import Markdown
```

## Build and verification

```bash
git submodule update --init --recursive
./Scripts/test-patch.sh
./Scripts/test-source.sh
./Scripts/build-xcframework.sh
./Scripts/test-swiftpm.sh
./Scripts/test-cocoapods.sh
```

The XCFramework contains static libraries for iOS arm64 devices and iOS arm64
simulators. Generated archives and zip files are ignored by Git.

## Release

1. Manually commit the new version to `VERSION` on `main`.
2. Run the `Release` workflow manually from `main`.
3. The workflow builds and tests the artifact, updates checksums, commits the
   metadata, creates a `swift-markdown-<version>` tag, and uploads the zip to a
   GitHub Release.

The workflow rejects other branches and existing tags. CocoaPods downloads the
zip directly from the GitHub Release URL.
