#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Vendor/swift-markdown"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --quiet --no-hardlinks "$SOURCE_DIR" "$WORK_DIR/swift-markdown"
git -C "$WORK_DIR/swift-markdown" apply "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"
ditto "$ROOT_DIR/Tests/PatchTests/DoubleTildeTests.swift" \
  "$WORK_DIR/swift-markdown/Tests/MarkdownTests/DoubleTildeTests.swift"

swift test --package-path "$WORK_DIR/swift-markdown" --filter DoubleTildeTests
