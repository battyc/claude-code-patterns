# Meta Repo

Use a wrapper repo as the workspace root to give Claude Code full context across multiple independent source repos.

## Problem

When a project spans multiple repositories with separate permissions and Git histories, Claude Code has no single root directory with full context. Opening one repo at a time means Claude can't see how the pieces fit together, leading to incomplete suggestions and missed cross-repo dependencies.

## Solution

Create a meta repository as the developer workspace root. It holds what spans the repos: how they relate, architecture notes, decision records, runbooks and setup tooling. The source repos are cloned into a gitignored `packages/` directory, each keeping its own independent Git history and remote. Claude Code is opened at the meta repo root and can read across all of `packages/` to understand the full system.

Guidance about one repo lives in that repo, not in the meta repo:

- Each package keeps its real instructions in `AGENTS.md`, with a one-line `CLAUDE.md` that imports it (`@AGENTS.md`). Other coding agents read `AGENTS.md`; Claude Code reads the shim.
- The meta repo's `CLAUDE.md` describes only the cross-repo picture, then imports each package's `CLAUDE.md` (`@packages/<repo>/CLAUDE.md`).

Opening the meta repo loads the whole chain. Opening a single package, or a workspace where the repos are cloned side by side without the meta repo's `packages/` layout, still loads that package's own guidance, so nothing about a package depends on the meta repo being present.

Commands and settings shared by everyone go in the meta repo's `.claude/` directory and are committed. Only `.claude/settings.local.json`, which holds personal settings, is ignored.

## When to Use

- Project spans 2+ repos developed together
- Different repos have different permission models
- You want Claude Code to understand the full system from a single root
- You want to version docs and architecture decisions without coupling them to source repos

## Directory Structure

```
<meta-repo>/
├── .gitignore           # ignores packages/ and .claude/settings.local.json
├── .claude/
│   └── commands/        # shared slash commands, committed
├── CLAUDE.md            # cross-repo context, then imports each package's CLAUDE.md
├── architecture.md      # how the repos relate and interact
├── docs/
│   ├── runbooks/        # operational procedures
│   └── decisions/       # architecture decision records (ADRs)
├── hooks/
│   └── pre-commit       # optional hook source — install it by hand
├── scripts/
│   └── setup.sh         # clones source repos into packages/
└── packages/            # gitignored — each subdir is its own repo
    ├── <repo-1>/
    │   ├── AGENTS.md    # the package's real instructions
    │   └── CLAUDE.md    # one line: @AGENTS.md
    ├── <repo-2>/
    └── <repo-3>/
```

## Setup

1. Create your meta repo and clone it locally
2. Copy the files from `template/` into the repo root
3. Edit `scripts/setup.sh` with your actual repo URLs, and run it. It skips repos already cloned, so it's safe to run again after adding one.
4. Write your `CLAUDE.md` describing how the repos relate, and list each package's `CLAUDE.md` under "Instructions per package"
5. In each package, put its instructions in `AGENTS.md` and add a `CLAUDE.md` containing `@AGENTS.md`
6. Write `architecture.md` covering data flow and CI/CD wiring
7. Optionally add the pre-commit hook to prevent accidental staging of `packages/` contents:
   ```
   cp hooks/pre-commit .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

## Template Files

| File | Purpose |
|------|---------|
| `.gitignore` | Ignores `packages/` and personal Claude Code settings, so shared `.claude/` files can be committed |
| `scripts/setup.sh` | Clones source repos into `packages/`, skipping any already there; an optional repo is gated on an environment variable |
| `CLAUDE.md` | Starter context file — repo table, relationships, workflows, known issues, and the per-package imports |
| `architecture.md` | Starter architecture doc — describe data flow and repo responsibilities |
| `docs/decisions/001-example.md` | Example ADR to use as a starting point |
| `hooks/pre-commit` | Optional hook to prevent accidentally staging files under `packages/` |

## Tradeoffs

- Adds an extra repo to manage — worth it only when you have 2+ source repos
- Developers must remember to run `setup.sh` after cloning
- Changes to `CLAUDE.md` and architecture docs require their own commit cycle
- Importing every package's instructions puts all of them in context in every session, even one that only touches one package. Keep each package's file to what someone working in it needs.
- Facts duplicated across repos, such as resource IDs one repo hardcodes from another, aren't kept in sync by anything. Name them in the meta `CLAUDE.md` so a change to one side prompts a change to the other.
- IDE features may need extra config to resolve paths across `packages/` subdirectories
