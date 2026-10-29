#!/usr/bin/env bash
# Passive DNS and email-authentication checks: MX, SPF, DMARC, common DKIM
# selectors, CAA, DNSSEC, MTA-STS, TLS-RPT, BIMI.
# Usage: scripts/check-dns.sh example.com [output-dir]
set -uo pipefail

. "$(cd "$(dirname "$0")" && pwd)/lib/validate.sh"
DOMAIN="$(clean_domain "${1:?usage: check-dns.sh <domain> [output-dir]}")" || exit 2
DOMAIN="${DOMAIN#www.}"
RUN="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}"; check_out "$RUN"
OUT="$RUN/evidence"
mkdir -p "$OUT"
command -v dig >/dev/null || { echo "dig is required (macOS has it; on Linux install dnsutils or bind-utils)"; exit 1; }

{
  for t in A AAAA NS MX CAA; do echo "== $t"; dig +short "$t" "$DOMAIN"; done
  echo "== www"; dig +short "www.$DOMAIN"
  echo "== TXT (SPF and verification records)"; dig +short TXT "$DOMAIN"
  echo "== DMARC (_dmarc)"; dig +short TXT "_dmarc.$DOMAIN"
  echo "== MTA-STS"; dig +short TXT "_mta-sts.$DOMAIN"
  echo "== TLS-RPT"; dig +short TXT "_smtp._tls.$DOMAIN"
  echo "== BIMI"; dig +short TXT "default._bimi.$DOMAIN"
  echo "== DKIM (common selectors; none found does NOT prove DKIM is off, see docs/email-headers.md)"
  for s in selector1 selector2 google default k1 k2 s1 s2 dkim mail smtp mxvault zoho protonmail fm1 fm2 mandrill; do
    r="$(dig +short TXT "$s._domainkey.$DOMAIN")$(dig +short CNAME "$s._domainkey.$DOMAIN")"
    [ -n "$r" ] && echo "$s: $(echo "$r" | cut -c1-150)"
  done
  echo "== DNSSEC (DS record at the parent)"; dig +short DS "$DOMAIN" || true
} > "$OUT/dns.txt" 2>&1

if command -v whois >/dev/null; then
  whois "$DOMAIN" 2>/dev/null | grep -iE 'creation date|registrar:|registry expiry' | head -5 > "$OUT/whois.txt"
fi

cat "$OUT/dns.txt"
