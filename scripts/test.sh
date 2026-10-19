#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"
test_arch="${SPECTACLE_TEST_ARCH:-$(uname -m)}"
case "$test_arch" in
  arm64|x86_64) ;;
  *) echo "Unsupported test architecture: $test_arch" >&2; exit 2 ;;
esac

xcodebuild -project Spectacle.xcodeproj -scheme Spectacle \
  -configuration Debug -derivedDataPath "$repo_dir/build/DerivedData" \
  -destination "platform=macOS,arch=$test_arch" test
