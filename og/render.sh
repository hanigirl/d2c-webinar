#!/bin/sh
# Renders og/cover.html to assets/og-cover.jpg — the link preview card.
#
# 1200x630 is the box LinkedIn, WhatsApp, Facebook and X all crop from.
# Chrome only writes PNG and the card is photographic, so the PNG is an
# intermediate in a temp dir and the published asset is a JPEG: WhatsApp
# quietly skips previews over roughly 300KB.
#
# Served over http because Chrome blocks a file:// page from reading the
# sibling fonts and images it needs.
set -e
cd "$(dirname "$0")/.."

TMP=$(mktemp -d)
python3 -m http.server 8899 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null; rm -rf "$TMP"' EXIT
sleep 1

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --hide-scrollbars \
  --window-size=1200,630 \
  --screenshot="$TMP/cover.png" \
  "http://localhost:8899/og/cover.html" >/dev/null 2>&1

python3 - "$TMP/cover.png" <<'PY'
import sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGB")
im.save("assets/og-cover.jpg", "JPEG", quality=88, optimize=True, progressive=True)
print("wrote assets/og-cover.jpg", im.size)
PY
