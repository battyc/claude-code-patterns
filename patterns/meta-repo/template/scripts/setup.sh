#!/bin/bash
set -e
cd "$(dirname "$0")/.."
mkdir -p packages

clone() {
  if [ -d "packages/$2" ]; then
    echo "Skipping $2: already cloned"
  else
    git clone "$1" "packages/$2"
  fi
}

# Clone source repos — edit URLs and directory names to match your project
clone git@github.com:org/repo-1.git repo-1
clone git@github.com:org/repo-2.git repo-2

# Optional: a repo only some people have access to
if [ "${INCLUDE_CONTENT:-false}" = "true" ]; then
  clone git@github.com:org/repo-3.git repo-3
fi

echo "Done. Run 'cd packages/<repo>' to start working."
