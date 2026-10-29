#!/usr/bin/env bash
# Checks whether search and AI crawlers get the same pages a browser gets.
# This only tests user-agent strings; it can't prove what real crawler IPs see.
# Usage: scripts/crawler-access.sh example.com [output-dir]
set -uo pipefail

DOMAIN="${1:?usage: crawler-access.sh <domain> [output-dir]}"
DOMAIN="${DOMAIN#https://}"; DOMAIN="${DOMAIN#http://}"; DOMAIN="${DOMAIN%%/*}"
OUT="${2:-reviews/$DOMAIN-$(date +%Y-%m-%d)}/evidence"
mkdir -p "$OUT"

{
  printf "%-16s %-14s %s\n" "USER AGENT" "PATH" "STATUS BYTES"
  for ua in Browser GPTBot OAI-SearchBot ClaudeBot PerplexityBot Googlebot Bingbot; do
    case $ua in
      Browser) agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36" ;;
      *) agent="Mozilla/5.0 (compatible; $ua/1.0)" ;;
    esac
    for p in / /robots.txt /sitemap.xml /llms.txt; do
      printf "%-16s %-14s %s\n" "$ua" "$p" "$(curl -sS -A "$agent" -o /dev/null -w '%{http_code} %{size_download}' "https://$DOMAIN$p")"
    done
  done
} > "$OUT/crawler-access.txt" 2>&1

cat "$OUT/crawler-access.txt"
