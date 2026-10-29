#!/usr/bin/env bash
# Passive DNS and email-authentication checks: MX, SPF, DMARC, common DKIM
# selectors, CAA, DNSSEC, MTA-STS, TLS-RPT, BIMI.
# Usage: scripts/check-dns.sh example.com [output-dir]
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/validate.sh"
DOMAIN="$(clean_domain "${1:?usage: check-dns.sh <domain> [output-dir]}")" || exit 2
DOMAIN="${DOMAIN#www.}"
RUN="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}"; check_out "$RUN"
OUT="$RUN/evidence"
mkdir -p "$OUT"
# Use dig when it's installed (macOS; Linux with dnsutils or bind-utils).
# Windows has no dig, so fall back to Node's resolver (no DNSSEC check).
if command -v dig >/dev/null; then
  q() { dig +short "$@"; }
else
  echo "dig not found; using Node's DNS resolver instead (DNSSEC is not checked)."
  q() { node "$HERE/lib/dns-lookup.mjs" "$@"; }
fi

{
  for t in A AAAA NS MX CAA; do echo "== $t"; q "$t" "$DOMAIN"; done
  echo "== www"; q A "www.$DOMAIN"
  echo "== TXT (SPF and verification records)"; q TXT "$DOMAIN"
  echo "== DMARC (_dmarc)"; q TXT "_dmarc.$DOMAIN"
  echo "== MTA-STS"; q TXT "_mta-sts.$DOMAIN"
  echo "== TLS-RPT"; q TXT "_smtp._tls.$DOMAIN"
  echo "== BIMI"; q TXT "default._bimi.$DOMAIN"
  echo "== DKIM (common selectors; none found does NOT prove DKIM is off, see docs/email-headers.md)"
  for s in selector1 selector2 google default k1 k2 s1 s2 dkim mail smtp mxvault zoho protonmail fm1 fm2 mandrill; do
    r="$(q TXT "$s._domainkey.$DOMAIN")$(q CNAME "$s._domainkey.$DOMAIN")"
    [ -n "$r" ] && echo "$s: $(echo "$r" | cut -c1-150)"
  done
  echo "== DNSSEC (DS record at the parent)"; q DS "$DOMAIN" || true
} > "$OUT/dns.txt" 2>&1

if command -v whois >/dev/null; then
  whois "$DOMAIN" 2>/dev/null | grep -iE 'creation date|registrar:|registry expiry' | head -5 > "$OUT/whois.txt"
fi

cat "$OUT/dns.txt"
