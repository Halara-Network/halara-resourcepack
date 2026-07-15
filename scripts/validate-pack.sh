#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to validate the resource pack." >&2
  exit 1
fi

while IFS= read -r -d '' file; do
  jq empty "$file"
done < <(find . -type f -name '*.json' -print0)

jq -e '.pack.min_format == [88, 0] and .pack.max_format == [88, 0]' pack.mcmeta >/dev/null

while IFS= read -r reference; do
  path=${reference#halara:}
  if [[ ! -f "assets/halara/models/${path}.json" ]]; then
    echo "Missing Halara model: $reference" >&2
    exit 1
  fi
done < <(
  find assets/minecraft/items -type f -name '*.json' -print0 |
    xargs -0 jq -r '.. | objects | .model? // empty | select(type == "string") | select(startswith("halara:"))'
)

while IFS= read -r reference; do
  path=${reference#halara:}
  if [[ ! -f "assets/halara/textures/${path}.png" ]]; then
    echo "Missing Halara texture: $reference" >&2
    exit 1
  fi
done < <(
  find assets/halara/models -type f -name '*.json' -print0 |
    xargs -0 jq -r '.. | objects | .textures? // empty | objects | .[] | strings | select(startswith("halara:"))' |
    sort -u
)

while IFS=$'\t' read -r namespace path; do
  asset="assets/${namespace}/textures/${path}"
  if [[ "$asset" != *.png ]]; then
    asset="${asset}.png"
  fi
  if [[ ! -f "$asset" ]]; then
    echo "Missing bitmap font texture: ${namespace}:${path}" >&2
    exit 1
  fi
done < <(
  find assets -path '*/font/*.json' -type f -print0 |
    xargs -0 jq -r '.. | objects | .file? // empty | select(type == "string") | select(contains(":"))' |
    awk -F: '{print $1 "\t" $2}' |
    sort -u
)

echo "Halara resource pack is valid for Minecraft 26.2 (format 88.0)."
