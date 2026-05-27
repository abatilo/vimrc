---
name: repo-explore
description: Clone and explore external GitHub repositories to understand how libraries, frameworks, or dependencies work. Use when the user provides a GitHub URL or owner/repo shorthand, asks how an external package works, wants source-code details for a dependency, asks to explore or check out a repository, or needs the exact implementation for the version used by the current project.
metadata:
  short-description: Explore external GitHub repos locally
---

# Repo Explore

Use this skill to answer source-based questions about external GitHub
repositories. Clone or refresh the target repo in a local cache, align the
checkout to the version used by the current project when possible, then inspect
the cached source with normal repo-reading tools.

## Cache Location

```text
~/.cache/codex/repos/<owner>/<repo>/
```

## Workflow

1. Parse the repository identifier.
   - Accept `https://github.com/owner/repo`, `git@github.com:owner/repo.git`,
     `github.com/owner/repo`, or `owner/repo`.
   - Strip trailing `.git` and slashes.

2. Prepare the cached checkout.
   - If `~/.cache/codex/repos/<owner>/<repo>/` exists, inspect its current
     state and refresh only when needed.
   - If it does not exist, clone with:
     ```bash
     mkdir -p ~/.cache/codex/repos/<owner>
     git clone https://github.com/<owner>/<repo>.git ~/.cache/codex/repos/<owner>/<repo>
     ```
   - For cache refreshes, branch switches, tag switches, or repair steps, read
     `references/update-reference.md`.

3. Align to the relevant version before exploring.
   - First check whether the repository is a dependency of the current working
     project.
   - Read `references/version-detection.md` for dependency files to inspect and
     tag-mapping patterns by ecosystem.
   - If a matching version or tag is found, fetch tags and check it out before
     reading code.
   - If the user asks for a specific branch, tag, or commit, use that explicit
     revision even if the current project depends on a different version.

4. Explore the cached source.
   - For broad architecture questions, use a focused exploration sub-agent if
     the current Codex environment exposes one. Give it the cache path, the
     question, and the response requirements below.
   - If no suitable sub-agent is available, inspect directly with `rg`, `git`,
     and targeted file reads. Prefer source files, tests, and local docs over
     guesses.
   - Always verify the checkout with `git status --short --branch`,
     `git rev-parse HEAD`, and, when relevant, `git describe --tags --always`.

5. Answer from evidence.
   - State which repo path and revision were inspected.
   - Include file paths and line numbers for important claims.
   - Show short code snippets only when they directly support the answer.
   - End with a `Key Files for Further Exploration` table.

## Response Requirements

When answering questions about the repository, include:

- A brief answer summary.
- The source-backed explanation, with file paths and line numbers.
- Relevant function signatures, type definitions, or key logic snippets.
- A `Key Files for Further Exploration` table with 3-7 files:

```markdown
## Key Files for Further Exploration

| File | Purpose | Start Here If... |
|------|---------|------------------|
| `pkg/apis/v1/types.go` | Core type definitions | You want the data model |
| `pkg/controller/main_controller.go` | Main control flow | You want request handling |
| `docs/design.md` | Architecture notes | You want high-level design context |
```

## Important Notes

- Mention if no matching dependency version could be found and explain which
  revision you selected instead.
- For private repositories, use the user's configured Git credentials.
- Large repositories may take time to clone or fetch; keep the user informed.
- Do not delete cached repositories or force-reset dirty cached checkouts unless
  the user asks or the cache is clearly corrupt and the deletion is limited to
  the cached external repo.
