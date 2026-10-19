#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"
check_only=false
case "${1:-}" in
  --check-only) check_only=true ;;
  '') ;;
  *) echo 'Usage: build-store.sh [--check-only]' >&2; exit 2 ;;
esac
python3 scripts/verify-shortcut.py
companion='Spectacle/Resources/Shortcuts/Spectacle Window Bridge.shortcut'
if [[ "$check_only" == false && ! -f "$companion" ]]; then
  echo 'The signed companion Shortcut is missing. See docs/SHORTCUTS_BACKEND.md.' >&2
  exit 1
fi
xcodebuild -project Spectacle.xcodeproj -scheme 'Spectacle Store' \
  -configuration Store -derivedDataPath "$repo_dir/build/StoreDerivedData" \
  -destination 'generic/platform=macOS' ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO build
app="$repo_dir/build/StoreDerivedData/Build/Products/Store/Spectacle.app"
"$repo_dir/scripts/verify-universal.sh" "$app"
/usr/bin/codesign --verify --deep --strict "$app"
entitlements="$repo_dir/build/StoreDerivedData/store-entitlements.plist"
/usr/bin/codesign -d --entitlements - --xml "$app" > "$entitlements"
python3 - "$entitlements" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'rb') as handle:
    values = plistlib.load(handle)
assert values.get('com.apple.security.app-sandbox') is True
assert values.get('com.apple.security.scripting-targets') == {'com.apple.shortcuts.events': ['com.apple.shortcuts.run']}
assert not values.get('com.apple.security.get-task-allow')
assert not any('temporary-exception' in key for key in values)
PY
symbols="$repo_dir/build/StoreDerivedData/undefined-symbols.txt"
/usr/bin/nm -u "$app/Contents/MacOS/Spectacle" > "$symbols"
if /usr/bin/grep -Eq 'AXUIElement|AXIsProcessTrusted|LSSharedFileList' "$symbols"; then
  echo 'The Store executable unexpectedly references the legacy window or login APIs.' >&2
  exit 1
fi
if [[ "$check_only" == true ]]; then
  printf '\nStore build and sandbox verified. Validation only; no distributable archive created.\n'
  exit 0
fi
cmp "$companion" "$app/Contents/Resources/Shortcuts/Spectacle Window Bridge.shortcut"
mkdir -p "$repo_dir/build/dist"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" "$repo_dir/build/dist/Spectacle-Shortcuts-universal.zip"
printf '\nApplication: %s\nArchive: %s\n' "$app" "$repo_dir/build/dist/Spectacle-Shortcuts-universal.zip"
