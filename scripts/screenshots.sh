#!/usr/bin/env bash
# Fallback screenshots with headless Chrome, for agents without browser tools.
# Takes a desktop (1440x900) and phone-width (390x844) first-screen capture.
# Usage: scripts/screenshots.sh https://example.com/page [output-dir]
set -uo pipefail

. "$(cd "$(dirname "$0")" && pwd)/lib/validate.sh"
URL="${1:?usage: screenshots.sh <url> [output-dir]}"; check_url "$URL"
DOMAIN=$(echo "$URL" | sed -E 's#^https?://##; s#[:/].*##')
RUN="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}"; check_out "$RUN"
OUT="$RUN/shots"
NAME=$(echo "$URL" | sed -E 's#^https?://[^/]+/?##; s#[?\#].*##; s#/$##; s#[^A-Za-z0-9_-]#_#g'); [ -z "$NAME" ] && NAME=home
mkdir -p "$OUT"

CHROME="${CHROME:-}"
# Windows (Git Bash): Chrome installs for all users under Program Files, or per user under %LOCALAPPDATA%.
WIN_USER_CHROME=""
[ -n "${LOCALAPPDATA:-}" ] && command -v cygpath >/dev/null && WIN_USER_CHROME="$(cygpath -u "$LOCALAPPDATA")/Google/Chrome/Application/chrome.exe"
for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" google-chrome chromium chromium-browser \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" "$WIN_USER_CHROME"; do
  [ -z "$CHROME" ] && { [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; } && CHROME="$c"
done
[ -z "$CHROME" ] && { echo "Chrome not found. Set CHROME=/path/to/chrome"; exit 1; }

# Chrome needs an absolute output path; on Windows, in Windows form.
SAVE="$(cd "$OUT" && pwd)"
command -v cygpath >/dev/null && SAVE="$(cygpath -w "$SAVE")"

"$CHROME" --headless=new --hide-scrollbars --window-size=1440,900 --screenshot="$SAVE/desktop-$NAME.png" -- "$URL" 2>/dev/null
"$CHROME" --headless=new --hide-scrollbars --window-size=390,844 --user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148" \
  --screenshot="$SAVE/mobile-$NAME.png" -- "$URL" 2>/dev/null
ls -1 "$OUT"/*-"$NAME".png
