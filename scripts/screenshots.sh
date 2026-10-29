#!/usr/bin/env bash
# Fallback screenshots with headless Chrome, for agents without browser tools.
# Takes a desktop (1440x900) and phone-width (390x844) first-screen capture.
# Usage: scripts/screenshots.sh https://example.com/page [output-dir]
set -uo pipefail

URL="${1:?usage: screenshots.sh <url> [output-dir]}"
DOMAIN=$(echo "$URL" | sed -E 's#^https?://##; s#/.*##')
OUT="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}/shots"
NAME=$(echo "$URL" | sed -E 's#^https?://[^/]+/?##; s#/$##; s#/#_#g'); [ -z "$NAME" ] && NAME=home
mkdir -p "$OUT"

CHROME="${CHROME:-}"
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" google-chrome chromium chromium-browser; do
  [ -z "$CHROME" ] && { [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; } && CHROME="$c"
done
[ -z "$CHROME" ] && { echo "Chrome not found. Set CHROME=/path/to/chrome"; exit 1; }

"$CHROME" --headless=new --hide-scrollbars --window-size=1440,900 --screenshot="$OUT/desktop-$NAME.png" "$URL" 2>/dev/null
"$CHROME" --headless=new --hide-scrollbars --window-size=390,844 --user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148" \
  --screenshot="$OUT/mobile-$NAME.png" "$URL" 2>/dev/null
ls -1 "$OUT"/*-"$NAME".png
