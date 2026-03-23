# Meta Repo

Use a wrapper repo as the workspace root to give Claude Code full context across multiple independent source repos.

## Problem

When a project spans multiple repositories with separate permissions and Git histories, Claude Code has no single root directory with full context. Opening one repo at a time means Claude can't see how the pieces fit together, leading to incomplete suggestions and missed cross-repo dependencies.

## Solution

Create a meta repository as the developer workspace root. It holds documentation, architecture context, and setup tooling. Actual source repos are cloned into a gitignored `packages/` directory, each keeping its own independent Git history and remote. Claude Code is opened at the meta repo root and can read across all of `packages/` to understand the full system.

## When to Use

- Project spans 2+ repos developed together
- Different repos have different permission models
- You want Claude Code to understand the full system from a single root
- You want to version docs and architecture decisions without coupling them to source repos

## Directory Structure

```
<meta-repo>/
├── .gitignore           # ignores packages/ and .claude/
├── CLAUDE.md            # top-level Claude Code context
├── architecture.md      # how the repos relate and interact
├── docs/
│   ├── runbooks/        # operational procedures
│   └── decisions/       # architecture decision records (ADRs)
├── hooks/
│   └── pre-commit       # optional hook source — install via setup.sh
├── scripts/
│   └── setup.sh         # clones source repos into packages/
└── packages/            # gitignored — each subdir is its own repo
    ├── <repo-1>/
    ├── <repo-2>/
    └── <repo-3>/
```

## Setup

1. Create your meta repo and clone it locally
2. Copy the files from `template/` into the repo root
3. Edit `scripts/setup.sh` with your actual repo URLs
4. Write your `CLAUDE.md` describing how the repos relate
5. Write `architecture.md` covering data flow and CI/CD wiring
6. Optionally add the pre-commit hook to prevent accidental staging of `packages/` contents:
   ```
   cp hooks/pre-commit .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

## Template Files

| File | Purpose |
|------|---------|
| `.gitignore` | Ignores the `packages/` directory and `.claude/` (local Claude Code settings) |
| `scripts/setup.sh` | Clones source repos into `packages/` — edit URLs to match your project |
| `CLAUDE.md` | Starter Claude Code context file — fill in repo table and workflow details |
| `architecture.md` | Starter architecture doc — describe data flow and repo responsibilities |
| `docs/decisions/001-example.md` | Example ADR to use as a starting point |
| `hooks/pre-commit` | Optional hook to prevent accidentally staging files under `packages/` |

## Tradeoffs

- Adds an extra repo to manage — worth it only when you have 2+ source repos
- Developers must remember to run `setup.sh` after cloning
- Changes to `CLAUDE.md` and architecture docs require their own commit cycle
- IDE features may need extra config to resolve paths across `packages/` subdirectories
