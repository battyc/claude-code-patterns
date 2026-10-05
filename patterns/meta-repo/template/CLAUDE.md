# <Project Name>

This is the meta repo. Source code lives in `packages/` (gitignored).
Each subdirectory of `packages/` is an independent repo.

## Repo Structure

| Directory         | Repo                          | Purpose                        |
|-------------------|-------------------------------|--------------------------------|
| packages/repo-1/  | github.com/org/repo-1         | Describe what it does          |
| packages/repo-2/  | github.com/org/repo-2         | Describe what it does          |
| packages/repo-3/  | github.com/org/repo-3         | Describe what it does          |

Each package has its own `CLAUDE.md` with package-specific guidance. Start there when working inside a package.

## How They Relate

Describe the runtime/build-time relationships between repos.
e.g. "repo-2 consumes content from repo-3 at build time via X mechanism"

Call out anything duplicated across repos that has to change in both,
e.g. "repo-2 hardcodes resource IDs that repo-1 creates".

## Key Workflows

- **Local dev:** `cd packages/repo-1 && <start command>`
- **Deploy:** Triggered by push to repo-1 or repo-3 via CI
- **Content updates:** Handled entirely in repo-3, no code change needed
- **Fresh setup:** Run `scripts/setup.sh`. repo-3 is only cloned with `INCLUDE_CONTENT=true`.

## Known Issues

Problems that come from working across the repos at once, and their fixes.

## Access Notes

- `repo-3` has a separate set of collaborators — do not assume all devs have access
- See `architecture.md` for full system design

## Instructions per package

@packages/repo-1/CLAUDE.md

@packages/repo-2/CLAUDE.md

@packages/repo-3/CLAUDE.md
