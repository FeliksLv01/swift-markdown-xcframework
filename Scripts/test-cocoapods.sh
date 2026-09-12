#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

"$ROOT_DIR/Scripts/verify-xcframework.sh" "$ROOT_DIR/Markdown.xcframework"
ruby -e 'require "cocoapods"; Pod::Command.plugin_prefixes = []; Pod::Command.run(ARGV)' -- \
  lib lint "$ROOT_DIR/SwiftMarkdownBinary.podspec" \
  --allow-warnings \
  --platforms=ios \
  --verbose
