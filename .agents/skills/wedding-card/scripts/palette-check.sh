#!/usr/bin/env bash
# Report colour drift: hex literals in index.html that are not CSS :root tokens.
# Usage: bash .agents/skills/wedding-card/scripts/palette-check.sh [repo-root]
set -euo pipefail

root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
css="$root/styles.css"
html="$root/index.html"
[ -f "$css" ] && [ -f "$html" ] || { echo "not a wedding-card repo: $root" >&2; exit 2; }

tokens=$(sed -n '/^:root/,/^}/p' "$css" \
  | grep -oE '#[0-9A-Fa-f]{6}' | tr 'a-f' 'A-F' | sort -u)

echo "tokens in styles.css :root"
sed -n '/^:root/,/^}/p' "$css" | grep -E '^\s*--[a-z-]+:\s*#' | sed 's/^/  /'
echo

drift=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  hex=$(printf '%s' "$line" | grep -oE '#[0-9A-Fa-f]{6}' | tr 'a-f' 'A-F' | sort -u | tr '\n' ' ')
  for h in $hex; do
    [ "$h" = "#FFFFFF" ] && continue
    if ! printf '%s\n' "$tokens" | grep -qx "$h"; then
      [ "$drift" -eq 0 ] && echo "DRIFT — hex in index.html with no matching token:"
      drift=$((drift + 1))
      printf '  %s\n' "$(printf '%s' "$line" | cut -c1-120)"
      break
    fi
  done
done < <(grep -nE '#[0-9A-Fa-f]{6}' "$html")

if [ "$drift" -eq 0 ]; then
  echo "OK — every non-white hex in index.html matches a :root token."
else
  echo
  echo "$drift line(s) to update: garland bulbs, <symbol> fills/strokes, .swatches, meta theme-color."
  exit 1
fi
