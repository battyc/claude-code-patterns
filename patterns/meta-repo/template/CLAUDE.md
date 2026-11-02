# <Project Name>

This is the meta repo. The source repos, listed in `repos.txt`, are cloned into `packages/` (gitignored) by `scripts/setup.sh`, or beside this repo, as cloud sessions clone them. Each is an independent repo.

@context/system-map.md

## What this repo holds

- `context/system-map.md`: the section above, which `scripts/sync-context.sh` copies into a marked block in each package's `AGENTS.md`, so a session in one package knows the rest of the system. Edit it here, sync, and commit the result in each package.
- `context/session-start.sh`: copied to each package's `.claude/hooks/session-start.sh`, its Claude Code `SessionStart` hook. It runs `scripts/check-workspace.sh`, which reports a missing repo, a shallow clone, missing dependencies or a stale sync, each with the fix.
- `architecture.md`: how the repos relate. `docs/decisions/`: decisions that span repos (each repo keeps its own). `docs/runbooks/`: operations that touch more than one repo.

Call out anything duplicated across repos that has to change in both, such as resource IDs one repo hardcodes from another.

## Key Workflows

- **Local dev:** `cd packages/repo-1 && <start command>`
- **Deploy:** Triggered by push to repo-1 or repo-3 via CI
- **Fresh setup:** Run `scripts/setup.sh`. repo-3 is only cloned with `INCLUDE_CONTENT=true`. `git config core.hooksPath hooks` enables the hook that keeps `packages/` out of commits.

## Known Issues

Problems that come from working across the repos at once, and their fixes.

## Instructions per package

These imports read `packages/`; when the repos are cloned beside this one, each package's own `CLAUDE.md` still loads in a session opened there.

@packages/repo-1/CLAUDE.md

@packages/repo-2/CLAUDE.md

@packages/repo-3/CLAUDE.md
