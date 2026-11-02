#!/bin/bash
# Syncs the shared context into each package that opts in with the system-map markers in its
# AGENTS.md (a line starting `<!-- system-map:start` and a line `<!-- system-map:end -->`):
#
# - context/system-map.md replaces the block between the markers
# - context/session-start.sh is copied to the package's .claude/hooks/session-start.sh
#
# Usage: scripts/sync-context.sh [--check] [packages-dir]
#   --check writes nothing, and exits 1 if a sync would change anything.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

check=false
if [ "${1:-}" = "--check" ]; then check=true; shift; fi
packages="$(packages_dir "${1:-}")"

START="<!-- system-map:start: synced from $META_NAME/context/system-map.md by scripts/sync-context.sh; edit it there -->"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
changed=0

# Puts the contents of $tmp at $1 if they differ, or with --check only reports it
put() {
  if [ -f "$1" ] && cmp -s "$tmp" "$1"; then return; fi
  changed=1
  if $check; then echo "stale: $1"; else mkdir -p "$(dirname "$1")"; cp "$tmp" "$1"; echo "updated: $1"; fi
}

for name in $(repo_names); do
  dir="$packages/$name"
  agents="$dir/AGENTS.md"
  if ! is_cloned "$dir"; then echo "skipped: $name (not cloned in $packages)"; continue; fi
  if ! grep -q '^<!-- system-map:start' "$agents" 2>/dev/null; then echo "skipped: $name (no system-map markers in AGENTS.md)"; continue; fi
  if ! grep -q '^<!-- system-map:end -->' "$agents"; then echo "error: $agents has a system-map start marker but no end marker" >&2; exit 2; fi

  awk -v start="$START" -v map="$META_DIR/context/system-map.md" '
    /^<!-- system-map:start/ { print start; while ((getline line < map) > 0) print line; skipping = 1; next }
    /^<!-- system-map:end -->/ { skipping = 0 }
    !skipping { print }
  ' "$agents" > "$tmp"
  put "$agents"

  cp "$META_DIR/context/session-start.sh" "$tmp"
  put "$dir/.claude/hooks/session-start.sh"
done

if [ "$changed" = 0 ]; then echo "in sync"; fi
if $check && [ "$changed" = 1 ]; then exit 1; fi
exit 0
