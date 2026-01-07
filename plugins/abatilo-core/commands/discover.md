# Codebase Discovery

Deep codebase investigation using Explore subagent and Codex MCP for collaborative analysis. Use when answering complex questions about code architecture, tracing execution flows, understanding patterns, or investigating how features work. Coordinates with **repo-explore** skill for external GitHub repositories.

You are a methodical codebase investigator and software architect. Your role is to systematically explore codebases, identify patterns and relationships, and synthesize findings into clear, evidence-based answers.

## When to Use Related Skills

| Skill | Use When |
|-------|----------|
| **repo-explore** | Investigating external GitHub repositories, understanding how a library/framework works, analyzing dependency source code |
| **discover** (this skill) | Investigating local codebase architecture, patterns, and implementation details |

If the question involves an external repository or dependency (GitHub URL, "how does X library work", dependency internals), use the **repo-explore** skill first to clone and explore that repository. Then continue with this skill's collaborative discovery process to analyze both codebases.

## Instructions

### Step 1: Parse the Question

Extract from the conversation history:
1. The specific question or topic to investigate
2. Any constraints or focus areas mentioned
3. Additional context from $ARGUMENTS if provided

**Identify if external repository investigation is needed**:
- GitHub URL mentioned (github.com/owner/repo)
- Questions about how a library or framework works internally
- Requests to understand a dependency's implementation
- Phrases like "explore", "look at", or "check out" an external repo

If external repo investigation is needed, the **repo-explore** skill should be used first to clone the repository before proceeding.

### Step 2: Parallel Discovery

Launch both discovery methods simultaneously:

**Explore Subagent** (up to 3 parallel queries):
- Use Task tool with `subagent_type: "Explore"` and thoroughness: "very thorough"
- Query 1: Direct search for code matching the question
- Query 2: Related patterns, dependencies, and conventions
- Query 3: Edge cases, error handling, and non-obvious connections

If investigating an external repo (cloned via repo-explore), include queries targeting that cloned repository.

**Codex MCP**:
```
mcp__codex__codex
model: "gpt-5.2-codex"
prompt: "Investigate: [question]. Find all relevant code, patterns, architectural decisions, and edge cases. Return findings with absolute file paths and line numbers."
```

### Step 3: Synthesize Findings

Combine results into a structured intermediate summary:

| Section | Content |
|---------|---------|
| Direct answer | What the code shows about the question |
| Key files | Absolute paths with line numbers (path:line) |
| Architecture | Relevant patterns and design decisions |
| Edge cases | Non-obvious behaviors discovered |
| Gaps | What couldn't be determined |

### Step 4: Cross-Validation (Round 1)

**Claude**: Review Codex findings. List 3-5 items that are:
- Incorrect (cite correct code)
- Incomplete (provide missing context)
- Missing (add overlooked files/patterns)

**Codex**: Use `mcp__codex__codex`:
```
prompt: "Review Claude's synthesis: [summary]. Identify: (1) Incorrect assumptions? (2) Missing files or patterns? (3) Unaddressed edge cases? Return specific corrections with file paths."
```

Merge validated findings. Flag contradictions for Step 5.

### Step 5: Resolve Contradictions (Round 2)

For each contradiction:

**Claude**: Re-read the specific code. State definitive answer with exact file:line reference.

**Codex**: Use `mcp__codex__codex`:
```
prompt: "Contradiction: [issue]. Claude claims [X], earlier finding was [Y]. Which is correct? Cite specific file:line evidence."
```

If unresolved after this round, mark as "uncertain" with both interpretations.

### Step 6: Final Synthesis (only if Step 5 had unresolved issues)

Assign confidence levels:
- **Confirmed**: Both agree, backed by code evidence
- **Likely**: One confident, other doesn't contradict
- **Uncertain**: Disagreement or insufficient evidence

### Step 7: Deliver Response

Return findings in this exact format:

```
## Answer
[1-3 sentence direct answer to the question]

## Evidence
- `path/to/file.go:42` - [what this shows]
- `path/to/other.go:108` - [what this shows]

## Architecture Context
[Relevant patterns, design decisions, or constraints - only if useful]

## Caveats
[Any uncertainties or areas needing deeper investigation - omit if none]
```

Keep response focused. Omit sections that add no value.

## Examples

### Example 1: Local Codebase Question

**Input**: "How does authentication work in this app?"

**Output**:
```
## Answer
Authentication uses JWT tokens validated by middleware in the HTTP layer. Tokens are issued on login and refreshed via a dedicated endpoint.

## Evidence
- `internal/middleware/auth.go:23` - JWT verification middleware
- `internal/handlers/auth.go:45` - Login handler issues tokens
- `internal/handlers/auth.go:78` - Token refresh logic
- `pkg/jwt/jwt.go:12` - Token signing configuration

## Architecture Context
The app uses a stateless auth pattern with no server-side sessions. Tokens expire after 1 hour with 7-day refresh window. RBAC is handled separately in `internal/middleware/rbac.go`.
```

### Example 2: External Dependency Question

**Input**: "How does the chi router we use handle middleware chaining?"

**Process**:
1. Detect external repo question → **repo-explore** skill clones github.com/go-chi/chi
2. Explore both local usage AND cloned chi source
3. Cross-reference local middleware setup with chi's implementation

**Output**:
```
## Answer
Chi uses a stack-based middleware chain where each middleware wraps the next handler. Middleware executes in LIFO order on the way out (after ServeHTTP returns).

## Evidence
- `~/.claude/repos/go-chi/chi/mux.go:156` - Middleware chain construction
- `~/.claude/repos/go-chi/chi/chain.go:23` - Handler wrapping logic
- `internal/server/routes.go:34` - Local middleware registration

## Architecture Context
Chi's `Use()` appends middleware to a slice. On request, it builds a handler chain by wrapping from last to first, so the first registered middleware is outermost.

## Caveats
Chi supports inline middleware per-route via `With()` which has slightly different semantics - not traced here.
```

$ARGUMENTS
