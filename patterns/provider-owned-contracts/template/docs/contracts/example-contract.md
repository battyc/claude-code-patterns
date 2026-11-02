---
provider: this-repo
consumers: [other-repo]
---

# Example contract

What this interface is, in a sentence or two, and what the consumers rely on it for. Name the consumer's side by repo and path (other-repo's `src/api/client.ts`), as plain text.

## The contract

The shape each side relies on, specifically enough to check against the code: endpoints and response fields, commands and the environment they read, file formats and what fails on a bad one, names and IDs one side hardcodes from the other. A table often fits.

| Field | Type | Meaning |
|---|---|---|
| `status` | `"ok" \| "degraded"` | Example |

## Enforced by

- `test/example.test.ts` in this repo: what it fails on.
- other-repo's `tests/example.spec.ts`: what it checks from the consumer's side.

Whatever isn't tested is kept true by review; say so.

## Changing it

- **An addition** consumers can ignore: change it here with the code.
- **A change consumers depend on:** change it here first, check each consumer above in the same piece of work, and say in the PR which ones it needs.
- **A rename or removal:** add the new form first, move each consumer to it, then remove the old one.
