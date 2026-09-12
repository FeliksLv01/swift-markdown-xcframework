#!/bin/bash

set -euo pipefail

XCFRAMEWORK_PATH="${1:-Markdown.xcframework}"

if [[ ! -d "$XCFRAMEWORK_PATH" ]]; then
  echo "XCFramework not found: $XCFRAMEWORK_PATH" >&2
  exit 1
fi

LIBRARIES="$(/usr/libexec/PlistBuddy -c 'Print :AvailableLibraries' "$XCFRAMEWORK_PATH/Info.plist")"
grep -q 'SupportedPlatform = ios' <<< "$LIBRARIES"
grep -q 'SupportedPlatformVariant = simulator' <<< "$LIBRARIES"

FRAMEWORK_COUNT="$(find "$XCFRAMEWORK_PATH" -type d -name Markdown.framework | wc -l | tr -d ' ')"
if [[ "$FRAMEWORK_COUNT" != "2" ]]; then
  echo "Expected 2 framework slices, found $FRAMEWORK_COUNT" >&2
  exit 1
fi

while IFS= read -r framework; do
  binary="$framework/Markdown"
  file "$binary" | grep -q 'current ar archive'
  lipo -archs "$binary" | grep -Eq '(^| )arm64($| )'
  test -d "$framework/Modules/Markdown.swiftmodule"
  if grep -R -E '^import cmark_gfm(_extensions)?$' "$framework/Modules/Markdown.swiftmodule"; then
    echo "Public Swift interfaces expose private cmark modules" >&2
    exit 1
  fi
  ar -t "$binary" | grep -q 'cmark.o'
  ar -t "$binary" | grep -q 'strikethrough.o'
  ar -t "$binary" | grep -q 'CAtomic.o'
done < <(find "$XCFRAMEWORK_PATH" -type d -name Markdown.framework | sort)

echo "Verified static iOS device and arm64 simulator slices"
