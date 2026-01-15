# Conventional Commits Reference

This reference provides detailed guidance on the Conventional Commits specification.

## Specification Overview

Conventional Commits is a specification for adding human and machine readable meaning to commit messages.

### Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

### Primary Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | A new feature for the user | `feat: add user profile page` |
| `fix` | A bug fix for the user | `fix: resolve login timeout issue` |

### Secondary Types

| Type | When to Use | Example |
|------|-------------|---------|
| `docs` | Documentation only changes | `docs: update API reference` |
| `style` | Formatting, missing semicolons, etc. (no code change) | `style: fix indentation in utils.ts` |
| `refactor` | Code change that neither fixes a bug nor adds a feature | `refactor: extract validation logic` |
| `perf` | Performance improvement | `perf: optimize database queries` |
| `test` | Adding or updating tests | `test: add unit tests for auth service` |
| `build` | Changes to build system or dependencies | `build: upgrade webpack to v5` |
| `ci` | Changes to CI configuration | `ci: add GitHub Actions workflow` |
| `chore` | Other changes that don't modify src or test files | `chore: update .gitignore` |

## Scopes

Scopes provide additional contextual information about what part of the codebase is affected.

### Examples

```
feat(auth): add OAuth2 support
fix(api): handle null response from server
docs(readme): add installation instructions
refactor(utils): simplify date formatting functions
```

### Common Scope Patterns

- **By module**: `feat(auth)`, `fix(payments)`, `refactor(users)`
- **By layer**: `feat(api)`, `fix(ui)`, `refactor(db)`
- **By file type**: `style(css)`, `test(unit)`, `build(docker)`

## Breaking Changes

### Using BREAKING CHANGE footer

```
feat(api): change authentication endpoint

BREAKING CHANGE: The /auth endpoint now requires a JSON body instead of form data.
```

### Using ! shorthand

```
feat(api)!: change authentication endpoint

The /auth endpoint now requires a JSON body instead of form data.
```

## Body Guidelines

The body should:
- Explain the **motivation** for the change
- Contrast with **previous behavior**
- Be wrapped at **72 characters**

### Example

```
fix(auth): resolve session expiration race condition

Previously, sessions could expire while a request was in-flight, causing
intermittent 401 errors. This change adds a 30-second grace period to
session validation, preventing premature expiration during active use.

Fixes #123
```

## Footer Conventions

### Issue References

```
Fixes #123
Closes #456
Relates to #789
```

### Co-authors

```
Co-authored-by: Name <email@example.com>
```

### Reviewed-by

```
Reviewed-by: Name <email@example.com>
```

## Detection Heuristics

When analyzing a project's git history to detect conventional commits usage:

1. **Check the last 20-30 commits**
2. **Look for type prefixes**: `feat:`, `fix:`, `docs:`, etc.
3. **Check consistency**: If 80%+ use the format, follow it
4. **Note variations**: Some projects use `feat():` with empty scope, others never use scope

### Detection Regex

```regex
^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?!?:\s.+
```

## Common Mistakes

### Incorrect

```
feat added new feature          # Missing colon
Feat: add new feature          # Type should be lowercase
feat: Add new feature.         # Subject shouldn't end with period
feat: added new feature        # Should use imperative mood
```

### Correct

```
feat: add new feature
```

## Tools & Automation

Conventional Commits enable:

- **Automatic changelog generation**
- **Semantic versioning automation**
- **Filtering commits by type**
- **Triggering CI/CD pipelines based on commit type**

### Semantic Versioning Mapping

| Commit Type | Version Bump |
|-------------|--------------|
| `fix` | PATCH (0.0.X) |
| `feat` | MINOR (0.X.0) |
| `BREAKING CHANGE` | MAJOR (X.0.0) |
| Other types | No version bump |
