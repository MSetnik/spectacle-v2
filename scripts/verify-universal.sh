#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Spectacle.app" >&2
  exit 2
fi

app="$1"
executable="$app/Contents/MacOS/Spectacle"
if [[ ! -f "$executable" ]]; then
  echo "Missing Spectacle executable: $executable" >&2
  exit 1
fi

/usr/bin/lipo "$executable" -verify_arch arm64
/usr/bin/lipo "$executable" -verify_arch x86_64

# Check every Mach-O file, including any frameworks/helpers added in the future.
while IFS= read -r -d '' binary; do
  if [[ "$(/usr/bin/file -b "$binary")" == *Mach-O* ]]; then
    /usr/bin/lipo "$binary" -verify_arch arm64
    /usr/bin/lipo "$binary" -verify_arch x86_64
    printf '%s: %s\n' "$binary" "$(/usr/bin/lipo -archs "$binary")"
  fi
done < <(/usr/bin/find "$app" -type f -print0)
