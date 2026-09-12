#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Vendor/swift-markdown"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build/xcframework}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR}"
WORK_DIR="$BUILD_DIR/source"
DEVICE_ARCHIVE="$BUILD_DIR/Markdown-iOS.xcarchive"
SIMULATOR_ARCHIVE="$BUILD_DIR/Markdown-iOS-Simulator.xcarchive"
DEVICE_DERIVED_DATA="$BUILD_DIR/DerivedData-iOS"
SIMULATOR_DERIVED_DATA="$BUILD_DIR/DerivedData-iOS-Simulator"
OUTPUT_XCFRAMEWORK="$OUTPUT_DIR/Markdown.xcframework"

if [[ ! -f "$SOURCE_DIR/Package.swift" ]]; then
  echo "Missing swift-markdown submodule. Run: git submodule update --init --recursive" >&2
  exit 1
fi

rm -rf "$BUILD_DIR" "$OUTPUT_XCFRAMEWORK"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"
git clone --quiet --no-hardlinks "$SOURCE_DIR" "$WORK_DIR"

git -C "$WORK_DIR" apply --check "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"
git -C "$WORK_DIR" apply "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"
git -C "$WORK_DIR" apply --check "$ROOT_DIR/Patches/swift-markdown-0.8.0-static-framework.patch"
git -C "$WORK_DIR" apply "$ROOT_DIR/Patches/swift-markdown-0.8.0-static-framework.patch"

archive() {
  local destination="$1"
  local archive_path="$2"
  local derived_data_path="$3"
  shift 3

  (
    cd "$WORK_DIR"
    set -o pipefail
    xcodebuild archive \
      -scheme swift-markdown \
      -destination "$destination" \
      -archivePath "$archive_path" \
      -derivedDataPath "$derived_data_path" \
      -configuration Release \
      SKIP_INSTALL=NO \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
      MACH_O_TYPE=staticlib \
      CODE_SIGNING_ALLOWED=NO \
      "$@" 2>&1 | xcbeautify
  )
}

archive "generic/platform=iOS" "$DEVICE_ARCHIVE" "$DEVICE_DERIVED_DATA"
archive "generic/platform=iOS Simulator" "$SIMULATOR_ARCHIVE" "$SIMULATOR_DERIVED_DATA" \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=NO

install_swiftmodule() {
  local archive_path="$1"
  local derived_data_path="$2"
  local sdk_name="$3"
  local framework="$archive_path/Products/usr/local/lib/Markdown.framework"
  local module_dir

  module_dir="$(find "$derived_data_path" -type d -path "*Release-$sdk_name/Markdown.swiftmodule" | head -n 1)"
  if [[ -z "$module_dir" || ! -d "$framework" ]]; then
    echo "Missing framework or Swift module for $sdk_name" >&2
    exit 1
  fi
  mkdir -p "$framework/Modules"
  ditto "$module_dir" "$framework/Modules/Markdown.swiftmodule"
  while IFS= read -r interface; do
    sed -i '' \
      -e '/^import cmark_gfm$/d' \
      -e '/^import cmark_gfm_extensions$/d' \
      "$interface"
  done < <(find "$framework/Modules/Markdown.swiftmodule" -name '*.swiftinterface')
}

install_swiftmodule "$DEVICE_ARCHIVE" "$DEVICE_DERIVED_DATA" iphoneos
install_swiftmodule "$SIMULATOR_ARCHIVE" "$SIMULATOR_DERIVED_DATA" iphonesimulator

xcodebuild -create-xcframework \
  -framework "$DEVICE_ARCHIVE/Products/usr/local/lib/Markdown.framework" \
  -framework "$SIMULATOR_ARCHIVE/Products/usr/local/lib/Markdown.framework" \
  -output "$OUTPUT_XCFRAMEWORK"

"$ROOT_DIR/Scripts/verify-xcframework.sh" "$OUTPUT_XCFRAMEWORK"

echo "Created $OUTPUT_XCFRAMEWORK"
