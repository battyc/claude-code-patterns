# Contracts

Where this repo meets another, written down: the shape each side relies on, the test that enforces it, and how to change it safely.

- **Contracts this repo provides** are the files in this folder. This repo owns them: change one here, in the same PR as the code, and before any consumer relies on the change. Each names its consumers in front matter: check each one against a change in the same piece of work.
- **Contracts this repo depends on** are read where their provider keeps them, in its checkout beside this one, fetched to its latest `main`: the table names each path. Nothing is copied here. If a change here needs something a provider's contract doesn't say, change the provider first.
- **A contract links freely within its own repo**, and names anything in another repo by repo and path, as plain text.
- **Contracts with systems outside the project** are in [`external/`](external/). No repo provides them, so this repo owns them.

| Contract | Provider | Consumers |
|---|---|---|
| [Example contract](example-contract.md) | this repo | other-repo |
| Build interface, `docs/contracts/build-interface.md` | other-repo | this repo |

| External contract | System |
|---|---|
| [Example system](external/example-system.md) | What this repo relies on from it |
