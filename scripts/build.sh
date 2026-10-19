#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"

xcodebuild -project Spectacle.xcodeproj -scheme Spectacle \
  -configuration Release -derivedDataPath "$repo_dir/build/DerivedData" \
  -destination 'generic/platform=macOS' \
  ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build

app="$repo_dir/build/DerivedData/Build/Products/Release/Spectacle.app"
"$repo_dir/scripts/verify-universal.sh" "$app"
/usr/bin/codesign --verify --deep --strict "$app"

mkdir -p "$repo_dir/build/dist"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" \
  "$repo_dir/build/dist/Spectacle-universal.zip"
printf '\nApplication: %s\nArchive: %s\n' "$app" "$repo_dir/build/dist/Spectacle-universal.zip"
