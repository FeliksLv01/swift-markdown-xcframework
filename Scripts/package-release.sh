#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
XCFRAMEWORK_PATH="$ROOT_DIR/Markdown.xcframework"
ZIP_PATH="$ROOT_DIR/Markdown.xcframework.zip"
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

"$ROOT_DIR/Scripts/verify-xcframework.sh" "$XCFRAMEWORK_PATH"
rm -f "$ZIP_PATH"
ditto "$XCFRAMEWORK_PATH" "$STAGING_DIR/Markdown.xcframework"
ditto "$ROOT_DIR/LICENSE" "$STAGING_DIR/LICENSE"
ditto "$ROOT_DIR/NOTICE" "$STAGING_DIR/NOTICE"
ditto -c -k --sequesterRsrc "$STAGING_DIR" "$ZIP_PATH"

SWIFTPM_CHECKSUM="$(swift package compute-checksum "$ZIP_PATH")"
SHA256="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"

echo "version=$VERSION"
echo "swiftpm_checksum=$SWIFTPM_CHECKSUM"
echo "sha256=$SHA256"
