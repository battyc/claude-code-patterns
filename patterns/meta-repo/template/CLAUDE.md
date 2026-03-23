# <Project Name>

## Repo Structure

This is the meta repo. Source code lives in `packages/` (gitignored).
Each subdirectory of `packages/` is an independent repo.

| Directory         | Repo                          | Purpose                        |
|-------------------|-------------------------------|--------------------------------|
| packages/repo-1/  | github.com/org/repo-1         | Describe what it does          |
| packages/repo-2/  | github.com/org/repo-2         | Describe what it does          |
| packages/repo-3/  | github.com/org/repo-3         | Describe what it does          |

## How They Relate

Describe the runtime/build-time relationships between repos.
e.g. "repo-2 consumes content from repo-3 at build time via X mechanism"

## Key Workflows

- **Local dev:** `cd packages/repo-1 && <start command>`
- **Deploy:** Triggered by push to repo-1 or repo-3 via CI
- **Content updates:** Handled entirely in repo-3, no code change needed

## Access Notes

- `repo-3` has a separate set of collaborators — do not assume all devs have access
- See `architecture.md` for full system design
