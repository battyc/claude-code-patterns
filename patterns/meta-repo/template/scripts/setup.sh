#!/bin/bash
set -e
mkdir -p packages

# Clone source repos — edit URLs and directory names to match your project
git clone git@github.com:org/repo-1.git packages/repo-1
git clone git@github.com:org/repo-2.git packages/repo-2

# Optional: only needed by some team members
if [ "${INCLUDE_CONTENT:-false}" = "true" ]; then
  git clone git@github.com:org/repo-3.git packages/repo-3
fi

echo "Done. Run 'cd packages/<repo>' to start working."
