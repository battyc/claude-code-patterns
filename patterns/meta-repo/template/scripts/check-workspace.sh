#!/bin/bash
# Reports whether the workspace is ready to work in: which repos are missing, which clones are
# shallow, whether the package in hand has its dependencies installed, and whether the synced
# context is current. Each problem comes with the command that fixes it. It informs rather than
# blocks: it always exits 0.
#
# Each package's .claude/hooks/session-start.sh runs it as Claude Code's SessionStart hook, so the
# session starts with its output. Other agents run it because the system map tells them to.
#
# Usage: scripts/check-workspace.sh [package-dir]
#   package-dir is the package the session works in; without it, every repo's dependencies are checked.
source "$(dirname "$0")/lib.sh"

package_dir=""
if [ -n "${1:-}" ]; then package_dir="$(cd "$1" && pwd)"; fi
if [ -n "$package_dir" ] && [ "$package_dir" != "$META_DIR" ]; then
  packages="$(packages_dir "$(dirname "$package_dir")")"
else
  packages="$(packages_dir)"
fi

problems=()
for dir in "$META_DIR" $(repo_names | sed "s|^|$packages/|"); do
  name="$(basename "$dir")"
  if ! is_cloned "$dir"; then
    gate="$(repo_gate "$name")"
    problems+=("$name is missing${gate:+ (optional; setup.sh clones it with $gate=true)}: clone it into $dir")
    continue
  fi
  if [ "$(git -C "$dir" rev-parse --is-shallow-repository)" = true ]; then
    problems+=("$name is a shallow clone: run \`git -C $dir fetch --unshallow\` before reasoning from its history")
  fi
  # Dependencies: adjust for your stack
  if { [ -z "$package_dir" ] || [ "$dir" = "$package_dir" ]; } && [ -f "$dir/package.json" ] && [ ! -d "$dir/node_modules" ]; then
    problems+=("$name has no node_modules: run \`npm ci\` in $dir before building or testing")
  fi
done

stale="$(bash "$META_DIR/scripts/sync-context.sh" --check "$packages" 2>&1 | grep -E '^(stale|error):' | sed "s|$packages/||")"
if [ -n "$stale" ]; then
  problems+=("the synced context is stale, so a system map or session-start hook may be out of date: run \`bash $META_DIR/scripts/sync-context.sh $packages\` and commit the result in each package. $(echo "$stale" | paste -sd ';' -)")
fi

echo "Workspace: $packages."
if [ ${#problems[@]} -eq 0 ]; then
  echo "Every repo is checked out with its full history, and the synced context is current."
else
  echo "Fix these before relying on the cross-repo docs:"
  printf -- '- %s\n' "${problems[@]}"
fi
exit 0
