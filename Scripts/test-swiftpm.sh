#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
XCFRAMEWORK_PATH="$ROOT_DIR/Markdown.xcframework"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

"$ROOT_DIR/Scripts/verify-xcframework.sh" "$XCFRAMEWORK_PATH"
ditto "$ROOT_DIR/Tests/SwiftPMConsumer" "$WORK_DIR/MarkdownConsumer"
ln -s "$XCFRAMEWORK_PATH" "$WORK_DIR/MarkdownConsumer/Markdown.xcframework"

(
  cd "$WORK_DIR/MarkdownConsumer"
  set -o pipefail
  xcodebuild build \
    -scheme MarkdownConsumer \
    -destination 'generic/platform=iOS' \
    CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify

  set -o pipefail
  xcodebuild build \
    -scheme MarkdownConsumer \
    -destination 'generic/platform=iOS Simulator' \
    ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify
)
