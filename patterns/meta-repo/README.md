# Meta Repo

A repo that holds what spans several source repos, and is the single source of what each of them needs to know about the others.

## Problem

When a project spans several repositories, some knowledge belongs to none of them: decisions that affect more than one repo, runbooks for operations that touch several, a plan across all of them, and the list of repos itself. Left in whichever repo happens to be nearest, it's out of sight of anyone working in the others.

The repos also need to know about each other. An agent working in one repo, often with only that repo open, can't see how it depends on the rest: it suggests a change to how the DNS zone is referenced without seeing how the zone is defined. Copying a description of the system into every repo by hand works until the copies disagree.

Opening every repo at once isn't the answer by itself: a cloud session already clones the repos side by side, and Claude Code can add sibling directories to a session. What's missing is a place for the shared knowledge, and a way for each repo to carry it.

## Solution

Create a meta repo. It holds no application code. It owns:

- **What spans the repos**: `architecture.md`, decisions that affect more than one repo, runbooks, and `repos.txt`, the list of repos that make up the workspace.
- **A system map** (`context/system-map.md`): a short description of every repo, how a change reaches production, and how to set up the workspace. `scripts/sync-context.sh` copies it into a marked block in each package's `AGENTS.md`, so a session opened in any one repo knows the rest. `--check` reports a copy that's out of date.
- **A session-start check** (`scripts/check-workspace.sh`): reports a missing repo, a shallow clone (whose history would mislead), missing dependencies and a stale sync, each with the command that fixes it. It never blocks the session. The sync copies `context/session-start.sh` into each package as its Claude Code `SessionStart` hook, which finds the meta repo and runs the check.

Guidance about one repo lives in that repo. Each package keeps its instructions in `AGENTS.md`, which other coding agents read natively, with a one-line `CLAUDE.md` that imports it (`@AGENTS.md`). The meta repo's `CLAUDE.md` imports the system map and each package's `CLAUDE.md`, so opening the meta repo loads the whole chain, and opening one package still loads that package's guidance.

The workspace has two layouts, and the scripts find either:

| Layout | Repos at | Made by |
|---|---|---|
| Inside | `<meta-repo>/packages/<repo>` (gitignored) | `scripts/setup.sh` |
| Beside | `<dir>/<repo>`, next to `<dir>/<meta-repo>` | Cloning each repo into one directory, as cloud sessions do |

Only the system map and the session-start hook are synced. Where the repos meet in a defined interface, write it down with the [provider-owned contracts](../provider-owned-contracts/README.md) pattern: each repo keeps its own, and the others read them in place.

## When to Use

- The project spans 2+ repos developed together, with enough that belongs to no one repo to need a home
- Sessions often have one repo open, and need to know what the others do
- Different repos have different permission models, so a monorepo isn't an option

If there's little cross-cutting to write down and sessions usually have every repo open, a parent directory (or `--add-dir`) and one repo that owns the shared notes is enough.

## Directory Structure

```
<meta-repo>/
├── .claude/
│   ├── settings.json      # runs the workspace check at session start
│   └── commands/          # shared slash commands, committed
├── .gitignore             # ignores packages/ and .claude/settings.local.json
├── CLAUDE.md              # imports the system map, then each package's CLAUDE.md
├── architecture.md        # how the repos relate and interact
├── repos.txt              # the repos in the workspace, read by every script
├── context/
│   ├── system-map.md      # synced into each package's AGENTS.md
│   └── session-start.sh   # synced into each package's .claude/hooks/
├── docs/
│   ├── runbooks/          # operations that touch more than one repo
│   └── decisions/         # decisions that span repos
├── hooks/
│   └── pre-commit         # refuses a commit that stages packages/
├── scripts/
│   ├── setup.sh           # clones repos.txt into packages/
│   ├── sync-context.sh    # the system map and hook into each package; --check
│   ├── check-workspace.sh # what's missing or stale, with the fix
│   └── lib.sh             # finds the workspace in either layout
└── packages/              # gitignored; or the repos sit beside the meta repo
    └── <repo>/
        ├── AGENTS.md      # the repo's instructions, with the system-map markers
        ├── CLAUDE.md      # one line: @AGENTS.md
        └── .claude/
            ├── settings.json            # runs the hook at session start
            └── hooks/session-start.sh   # synced from the meta repo
```

## Setup

1. Create the meta repo and copy `template/` into its root.
2. List your repos in `repos.txt`. A repo only some people can access gets a gate variable, and is cloned only when it's `true`.
3. Run `scripts/setup.sh`, or clone the repos beside the meta repo.
4. Set `META_REPO` in `context/session-start.sh` to the meta repo's directory name, and write `context/system-map.md`.
5. In each package, start from `package-template/`: instructions in `AGENTS.md` with the two system-map marker lines, a `CLAUDE.md` containing `@AGENTS.md`, and `.claude/settings.json`, whose hook does nothing until the first sync puts `session-start.sh` in place.
6. Run `scripts/sync-context.sh`, and commit the result in each package.
7. List each package's `CLAUDE.md` under "Instructions per package" in the meta `CLAUDE.md`, and write `architecture.md`.
8. Enable the pre-commit hook: `git config core.hooksPath hooks`.

After changing the system map or the hook, run `scripts/sync-context.sh` and commit in each package. The session-start check reports it if you forget.

## Template Files

| File | Purpose |
|---|---|
| `template/repos.txt` | The repos in the workspace: name, clone URL, optional gate variable |
| `template/scripts/setup.sh` | Clones `repos.txt` into `packages/`, skipping any already there, any gated off, and any directory in the way |
| `template/scripts/sync-context.sh` | Copies the system map into each package's marked block and the hook into its `.claude/hooks/`; `--check` exits 1 if anything is stale |
| `template/scripts/check-workspace.sh` | Reports missing repos, shallow clones, missing `node_modules` (adjust for your stack) and a stale sync; always exits 0 |
| `template/scripts/lib.sh` | Finds the meta repo and the packages, in either layout |
| `template/context/system-map.md` | Starter system map |
| `template/context/session-start.sh` | The packages' `SessionStart` hook: finds the meta repo beside or above the package and runs the check, or says how to get it |
| `template/.claude/settings.json` | Runs the check when a session starts in the meta repo |
| `template/CLAUDE.md` | Imports the system map and each package's `CLAUDE.md` |
| `template/architecture.md` | Starter architecture doc |
| `template/docs/decisions/001-example.md` | Example decision record |
| `template/hooks/pre-commit` | Refuses a commit that stages anything under `packages/` |
| `package-template/` | A package's `AGENTS.md` with the markers, its `CLAUDE.md` and `.claude/settings.json` |

## Tradeoffs

- **Another repo to keep current.** Its notes describe the others, and nothing checks `architecture.md` or a runbook against the code. Stale guidance is worse than none, because an agent acts on it. Keep the meta repo to what spans repos, and everything about one repo in that repo.
- **The system map is in every session.** It's copied into every `AGENTS.md`, so keep it to about twenty lines.
- **A sync is a commit in every package.** Changing the system map or the hook means a commit in each repo. That's acceptable for things that change rarely; it's why nothing else is synced.
- **The check informs, it doesn't fix.** It can't clone a private repo without credentials it can't assume, so it says what to run instead.
- **The hook is Claude Code's.** Other agents run the same check because the system map tells them to.
- **The package imports in the meta `CLAUDE.md` only resolve in the inside layout.** In the beside layout, each package's guidance loads from the package itself.
