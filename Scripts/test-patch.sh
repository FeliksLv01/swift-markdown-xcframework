#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Vendor/swift-markdown"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --quiet --no-hardlinks "$SOURCE_DIR" "$WORK_DIR/swift-markdown"
git -C "$WORK_DIR/swift-markdown" apply --check "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"
git -C "$WORK_DIR/swift-markdown" apply "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"
git -C "$WORK_DIR/swift-markdown" apply --reverse --check "$ROOT_DIR/Patches/swift-markdown-0.8.0-double-tilde.patch"

CHANGED_FILES="$(git -C "$WORK_DIR/swift-markdown" diff --name-only)"
if [[ "$CHANGED_FILES" != "Sources/Markdown/Parser/CommonMarkConverter.swift" ]]; then
  echo "Unexpected patched files: $CHANGED_FILES" >&2
  exit 1
fi

grep -q 'CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE' \
  "$WORK_DIR/swift-markdown/Sources/Markdown/Parser/CommonMarkConverter.swift"

echo "Patch validation passed"
