#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
app="$repo_dir/build/WindowFixture/Spectacle Window Test.app"
mkdir -p "$app/Contents/MacOS"
/usr/bin/clang -fobjc-arc -framework Cocoa -mmacosx-version-min=13.0 \
  "$repo_dir/tools/window-fixture/main.m" -o "$app/Contents/MacOS/WindowFixture"
/usr/bin/python3 - "$app/Contents/Info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'wb') as handle:
    plistlib.dump({
        'CFBundleIdentifier': 'io.github.msetnik.Spectacle.WindowFixture',
        'CFBundleName': 'Spectacle Window Test',
        'CFBundleExecutable': 'WindowFixture',
        'CFBundlePackageType': 'APPL',
        'CFBundleVersion': '1',
        'LSMinimumSystemVersion': '13.0',
        'NSHighResolutionCapable': True,
    }, handle)
PY
/usr/bin/codesign --force --sign - "$app"
printf '%s\n' "$app"
