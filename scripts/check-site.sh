#!/usr/bin/env bash
# Passive HTTP checks for one website: pages, timing, redirects, headers,
# robots/sitemap/llms.txt, missing-page behavior, and TLS.
# Usage: scripts/check-site.sh example.com [output-dir]
set -uo pipefail

DOMAIN="${1:?usage: check-site.sh <domain> [output-dir]}"
DOMAIN="${DOMAIN#https://}"; DOMAIN="${DOMAIN#http://}"; DOMAIN="${DOMAIN%%/*}"
OUT="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}/evidence"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"
BASE="https://$DOMAIN"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT/pages"

echo "Writing evidence to $OUT"

curl -sS -L -A "$UA" -o "$OUT/pages/root.html" "$BASE/" || { echo "Could not fetch $BASE/"; exit 1; }
node "$HERE/lib/discover-pages.mjs" "$DOMAIN" "$OUT/pages/root.html" > "$OUT/pages.txt"

{
  echo "== Pages (status, size, time to first byte, total) =="
  while read -r path; do
    name=$(echo "$path" | sed 's#^/##; s#/$##; s#/#_#g'); [ -z "$name" ] && name=root
    curl -sS -A "$UA" -o "$OUT/pages/$name.html" \
      -w "$path -> %{http_code} size=%{size_download} ttfb=%{time_starttransfer}s total=%{time_total}s %{redirect_url}\n" \
      "$BASE$path"
  done < "$OUT/pages.txt"

  echo; echo "== Missing-page behavior =="
  curl -sS -A "$UA" -o /dev/null -w "/this-page-should-not-exist-$$ -> %{http_code} %{redirect_url}\n" "$BASE/this-page-should-not-exist-$$"

  echo; echo "== Redirects =="
  for u in "http://$DOMAIN/" "http://www.$DOMAIN/" "https://www.$DOMAIN/"; do
    curl -sS -A "$UA" -o /dev/null -w "$u -> %{http_code} %{redirect_url}\n" "$u" 2>&1
  done

  echo; echo "== Standard files =="
  for f in robots.txt sitemap.xml sitemap_index.xml llms.txt .well-known/security.txt; do
    curl -sS -A "$UA" -o "$OUT/file-$(echo $f | tr / _)" -w "/$f -> %{http_code} bytes=%{size_download} type=%{content_type} %{redirect_url}\n" "$BASE/$f"
  done
} > "$OUT/http.txt" 2>&1

{
  echo "== Response headers for $BASE/ =="
  curl -sS -A "$UA" -D - -o /dev/null "$BASE/"
  echo "== Security header check =="
  hdrs=$(curl -sS -A "$UA" -D - -o /dev/null "$BASE/" | tr 'A-Z' 'a-z')
  for h in strict-transport-security content-security-policy x-frame-options x-content-type-options referrer-policy permissions-policy; do
    if echo "$hdrs" | grep -q "^$h:"; then echo "PRESENT  $h"; else echo "MISSING  $h"; fi
  done
} > "$OUT/headers.txt" 2>&1

{
  echo "== Certificate =="
  echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null
  echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | grep -E '^ *(Protocol|Cipher)|^New,' | head -3
  echo; echo "== Legacy TLS (1.0/1.1) =="
  echo "An 'alert protocol version' error means the server refuses old TLS (good)."
  echo "'No protocols available' or 'unsupported' means this computer can't test it."
  curl -sS -o /dev/null --tlsv1.0 --tls-max 1.1 -w '%{http_code}\n' "$BASE/" 2>&1 | head -2
} > "$OUT/tls.txt" 2>&1

node "$HERE/lib/page-meta.mjs" "$OUT/pages" > "$OUT/page-meta.txt"

echo "Done. Files: http.txt headers.txt tls.txt page-meta.txt pages.txt pages/"
grep -E 'MISSING|PRESENT' "$OUT/headers.txt"
