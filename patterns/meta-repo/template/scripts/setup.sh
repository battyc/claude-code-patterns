#!/bin/bash
# Clones the repos in repos.txt into packages/, skipping any already cloned. A repo with a gate
# variable is cloned only when that variable is "true", e.g. INCLUDE_CONTENT=true scripts/setup.sh
set -euo pipefail
source "$(dirname "$0")/lib.sh"
mkdir -p "$META_DIR/packages"

while read -r name url gate; do
  if is_cloned "$META_DIR/packages/$name"; then
    echo "Skipping $name: already cloned"
  elif [ -n "$gate" ] && [ "${!gate:-false}" != "true" ]; then
    echo "Skipping $name: set $gate=true to clone it"
  else
    git clone "$url" "$META_DIR/packages/$name"
  fi
done < <(repo_lines)

echo "Done. Run 'cd packages/<repo>' to start working."
