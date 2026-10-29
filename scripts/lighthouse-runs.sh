#!/usr/bin/env bash
# Runs Lighthouse performance several times on mobile and desktop and prints
# the median. One run is noise; report the median and the range.
# Usage: scripts/lighthouse-runs.sh https://example.com/ [runs] [output-dir]
set -uo pipefail

URL="${1:?usage: lighthouse-runs.sh <url> [runs] [output-dir]}"
RUNS="${2:-3}"
DOMAIN=$(echo "$URL" | sed -E 's#^https?://##; s#/.*##')
OUT="${3:-reviews/$DOMAIN-$(date +%Y-%m-%d)}/evidence/perf"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT"

for i in $(seq 1 "$RUNS"); do
  echo "mobile run $i of $RUNS"
  npx -y lighthouse@12 "$URL" --only-categories=performance --form-factor=mobile \
    --output=json --output-path="$OUT/mobile-$i.json" --chrome-flags="--headless=new" --quiet
  echo "desktop run $i of $RUNS"
  npx -y lighthouse@12 "$URL" --only-categories=performance --preset=desktop \
    --output=json --output-path="$OUT/desktop-$i.json" --chrome-flags="--headless=new" --quiet
done

node "$HERE/lib/lighthouse-summary.mjs" "$OUT" | tee "$OUT/summary.txt"
