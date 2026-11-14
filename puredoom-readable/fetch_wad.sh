#!/usr/bin/env bash
# Downloads the freedoom 0.13.0 release and extracts its freedoom2.wad beside this script (or into
# the folder given as $1). The zip and the wad are checked against the sha256 hashes c2das-re's
# VERSIONS.md pins. Idempotent: a wad with the pinned hash is kept.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
into=${1:-$here}
url=https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip
zip_hash=3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59
wad_hash=a8772e088847032510d97ba2312406a6998f21cbab44d4ff10696faa9c0ecd4b
wad="$into/freedoom2.wad"
if [ -f "$wad" ] && [ "$(sha256sum "$wad" | cut -d' ' -f1)" = "$wad_hash" ]; then
    echo "fetch_wad: $wad is the pinned freedoom2.wad"
    exit 0
fi
mkdir -p "$into"
tmp=$(mktemp -d)
trap 'rm -rf "${tmp:?}"' EXIT
curl -fsSL -o "$tmp/freedoom.zip" "$url"
have=$(sha256sum "$tmp/freedoom.zip" | cut -d' ' -f1)
[ "$have" = "$zip_hash" ] || { echo "fetch_wad: the zip has sha256 $have, want $zip_hash" >&2; exit 1; }
unzip -o -j -q "$tmp/freedoom.zip" '*/freedoom2.wad' -d "$tmp"
have=$(sha256sum "$tmp/freedoom2.wad" | cut -d' ' -f1)
[ "$have" = "$wad_hash" ] || { echo "fetch_wad: freedoom2.wad has sha256 $have, want $wad_hash" >&2; exit 1; }
mv "$tmp/freedoom2.wad" "$wad"
echo "fetch_wad: $wad"
