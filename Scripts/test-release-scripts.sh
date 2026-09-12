#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$WORK_DIR/Scripts"
ditto "$ROOT_DIR/Scripts/release-guard.sh" "$WORK_DIR/Scripts/release-guard.sh"
ditto "$ROOT_DIR/Scripts/update-release-metadata.rb" "$WORK_DIR/Scripts/update-release-metadata.rb"
ditto "$ROOT_DIR/VERSION" "$WORK_DIR/VERSION"

git -C "$WORK_DIR" init --quiet --initial-branch=main
git -C "$WORK_DIR" add VERSION Scripts
git -C "$WORK_DIR" -c user.name=CI -c user.email=ci@example.com commit --quiet -m init

VERSION="$(tr -d '[:space:]' < "$WORK_DIR/VERSION")"
TAG="swift-markdown-$VERSION"
[[ "$(GITHUB_REF=refs/heads/main "$WORK_DIR/Scripts/release-guard.sh")" == "$TAG" ]]

if GITHUB_REF=refs/heads/feature "$WORK_DIR/Scripts/release-guard.sh" >/dev/null 2>&1; then
  echo "Release guard accepted a non-main branch" >&2
  exit 1
fi

git -C "$WORK_DIR" tag "$TAG"
if GITHUB_REF=refs/heads/main "$WORK_DIR/Scripts/release-guard.sh" >/dev/null 2>&1; then
  echo "Release guard accepted an existing tag" >&2
  exit 1
fi

mkdir -p "$WORK_DIR/archive"
ditto "$WORK_DIR/VERSION" "$WORK_DIR/archive/VERSION"
ditto -c -k "$WORK_DIR/archive" "$WORK_DIR/Markdown.xcframework.zip"

cat > "$WORK_DIR/Package.swift" <<'EOF'
url: "https://example.com/releases/download/swift-markdown-old/Markdown.xcframework.zip",
checksum: "0000000000000000000000000000000000000000000000000000000000000000"
EOF
cat > "$WORK_DIR/SwiftMarkdownBinary.podspec" <<'EOF'
s.version = 'old'
:sha256 => '0000000000000000000000000000000000000000000000000000000000000000'
EOF

"$WORK_DIR/Scripts/update-release-metadata.rb" >/dev/null
grep -q "swift-markdown-$VERSION/Markdown.xcframework.zip" "$WORK_DIR/Package.swift"
if grep -q '0000000000000000000000000000000000000000000000000000000000000000' \
  "$WORK_DIR/Package.swift" "$WORK_DIR/SwiftMarkdownBinary.podspec"; then
  echo "Release metadata checksums were not updated" >&2
  exit 1
fi

echo "Release script tests passed"
