# Input checks shared by the scripts. The agent passes these arguments, and it
# reads untrusted web pages, so every argument is validated before use.

die() { echo "error: $*" >&2; exit 2; }

# A bare hostname: letters, digits, dots, hyphens; no leading hyphen.
clean_domain() {
  local d="${1#https://}"; d="${d#http://}"; d="${d%%/*}"
  [[ "$d" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || die "not a valid domain: $1"
  printf '%s' "$d"
}

# An http(s) URL with no spaces or quotes.
check_url() {
  [[ "$1" =~ ^https?://[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?(:[0-9]+)?(/[^[:space:]\"\'\`]*)?$ ]] || die "not a valid http(s) URL: $1"
}

check_int() {
  [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 10 ] || die "runs must be a number from 1 to 10: $1"
}

# Output must stay inside this repo's reviews/ folder.
check_out() {
  local repo; repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  case "$1" in
    -*|*..*) die "output folder not allowed: $1" ;;
    reviews/*|"$repo"/reviews/*) ;;
    *) die "output folder must be under reviews/: $1" ;;
  esac
}
