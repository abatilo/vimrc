---
paths:
  - "**/*.go"
---

# Go LSP (gopls) Usage

The `gopls-lsp` plugin is enabled. Use LSP operations proactively when working in Go codebases — don't rely solely on Grep/Glob/Read for code understanding.

## When to Use LSP

**Before editing a function or type:**
- `hover` on the symbol to confirm its type signature and docs
- `findReferences` to understand who depends on it (blast radius)
- `incomingCalls` to see all callers before changing a function's signature

**Before adding code:**
- `documentSymbol` on the target file to understand its structure
- `goToDefinition` on types/functions you'll interact with
- `workspaceSymbol` to find existing code you might reuse

**During refactors:**
- `findReferences` on every renamed/modified symbol to catch all call sites
- `goToImplementation` to find all concrete implementations of an interface
- `outgoingCalls` to understand a function's dependencies before moving or splitting it

**When exploring unfamiliar code:**
- `goToDefinition` to trace through call chains instead of guessing file locations
- `hover` for quick type info without reading entire files
- `incomingCalls` / `outgoingCalls` to map control flow

## Prefer LSP Over Text Search

- Use `goToDefinition` instead of grepping for a function name — it handles shadowing, packages, and vendored code correctly.
- Use `findReferences` instead of grepping for usages — it understands scope and won't return false positives from comments or strings.
- Use `workspaceSymbol` instead of globbing for type/function names — it searches the Go index, not filenames.

## Operations Reference

| Operation | Use for |
|---|---|
| `goToDefinition` | Navigate to a symbol's declaration |
| `findReferences` | All usages of a symbol across the project |
| `hover` | Type signature and docs at a position |
| `documentSymbol` | List all symbols in a file |
| `workspaceSymbol` | Search symbols across the workspace |
| `goToImplementation` | Find implementations of an interface |
| `prepareCallHierarchy` | Set up call hierarchy at a position |
| `incomingCalls` | Functions that call this function |
| `outgoingCalls` | Functions this function calls |
