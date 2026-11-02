# Sourced by the scripts beside it: where the workspace is.
#
# Two layouts work:
# - packages inside the meta repo, at <meta-repo>/packages/<repo>, as scripts/setup.sh clones them
# - packages beside it, at <dir>/<repo> next to <dir>/<meta-repo>, as cloud sessions clone them

META_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META_NAME="$(basename "$META_DIR")"

# Lines of repos.txt, without comments or blank lines: name url [gate]
repo_lines() { grep -v '^[[:space:]]*#' "$META_DIR/repos.txt" | awk 'NF'; }
repo_names() { repo_lines | awk '{ print $1 }'; }
repo_gate() { repo_lines | awk -v name="$1" '$1 == name { print $3 }'; }

is_cloned() { [ -e "$1/.git" ]; }

# The directory the packages are cloned in: the one given, else packages/ if any repo is there,
# else the meta repo's parent if any repo is there, else packages/
packages_dir() {
  if [ -n "${1:-}" ]; then (cd "$1" && pwd); return; fi
  local dir name
  for dir in "$META_DIR/packages" "$(dirname "$META_DIR")"; do
    for name in $(repo_names); do
      if is_cloned "$dir/$name"; then echo "$dir"; return; fi
    done
  done
  echo "$META_DIR/packages"
}
