#!/bin/sh
# Renders the social images from their HTML sources.
#
#   og/cover.html      -> assets/og-cover.jpg      1200x630, the link preview
#   og/instagram.html  -> og/instagram-post.jpg    1080x1080, a feed post
#
# 1200x630 is the box LinkedIn, WhatsApp, Facebook and X all crop from. Chrome
# only writes PNG and both cards are photographic, so the PNGs are intermediates
# in a temp dir and the published files are JPEGs: WhatsApp quietly skips link
# previews over roughly 300KB.
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

shoot() {   # shoot <source.html> <width> <height> <out.jpg>
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --headless --disable-gpu --hide-scrollbars \
    --window-size="$2,$3" \
    --screenshot="$TMP/shot.png" \
    "http://localhost:8899/og/$1" >/dev/null 2>&1

  python3 - "$TMP/shot.png" "$4" <<'PY'
import sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGB")
im.save(sys.argv[2], "JPEG", quality=88, optimize=True, progressive=True)
print("wrote", sys.argv[2], im.size)
PY
}

shoot cover.html     1200  630 assets/og-cover.jpg

# Instagram carousel, in order. Slide 4 is instagram.html — it doubles as the
# standalone feed post.
shoot slide-1.html   1080 1080 og/instagram-slide-1.jpg
shoot slide-2.html   1080 1080 og/instagram-slide-2.jpg
shoot slide-3.html   1080 1080 og/instagram-slide-3.jpg
shoot instagram.html 1080 1080 og/instagram-post.jpg
