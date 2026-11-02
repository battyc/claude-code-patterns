## The <project> system

This repo is one of <n> that make up <project>: <one sentence on what the system is>.

| Repo | Holds | Ships |
|---|---|---|
| `repo-1` | What it holds | How it deploys |
| `repo-2` | What it holds | How it deploys |
| `repo-3` | What it holds (private) | How it deploys |
| `my-meta-repo` | Cross-repo docs, decisions and runbooks, and the source of this section | Not deployed |

- How a change reaches production, and any order between repos (e.g. "deploy repo-1 by hand before anything in repo-2 that depends on it").
- Work in the workspace: `my-meta-repo`, with the other repos in its `packages/` or beside it. Start each session by running `bash .claude/hooks/session-start.sh` (Claude Code runs it for you; in the meta repo, `bash scripts/check-workspace.sh`): it reports a missing repo, a shallow clone, missing dependencies or a stale copy of this section, each with the command that fixes it.
