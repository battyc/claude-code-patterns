#!/bin/bash
# Synced from the meta repo's context/session-start.sh by its scripts/sync-context.sh; edit it there.
#
# Claude Code's SessionStart hook (.claude/settings.json): starts the session with the state of the
# workspace around this package, from the meta repo's scripts/check-workspace.sh. Any agent can run
# it by hand. It never fails the session.

META_REPO="my-meta-repo"   # the meta repo's directory name
package_dir="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# The meta repo is beside this package, or this package is in its packages/
for meta_dir in "$package_dir/../$META_REPO" "$package_dir/../.."; do
  if [ -f "$meta_dir/scripts/check-workspace.sh" ]; then
    bash "$meta_dir/scripts/check-workspace.sh" "$package_dir" || true
    exit 0
  fi
done

echo "$META_REPO isn't checked out, so nothing has checked that the other repos this package works with are here."
echo "Clone it beside this repo, then run \`bash ../$META_REPO/scripts/check-workspace.sh .\` to see what else is missing."
exit 0
