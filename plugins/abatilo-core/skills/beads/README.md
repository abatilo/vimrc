# Beads Skill for Claude Code

A Claude Code skill that teaches Claude how to use beads effectively for issue tracking in multi-session coding workflows.

## What is This?

This is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill - a markdown-based instruction set that teaches Claude AI how to use beads. It focuses on **decision-making patterns** and **workflow guidance** rather than CLI syntax (which is provided by `bd prime`).

## What Does It Provide?

**Main skill file (SKILL.md):**
- Decision criteria for when to use bd vs TodoWrite
- Notes format for compaction survival
- Pointer to `bd prime` for CLI reference
- Links to reference documentation

**Reference documentation:**
- `references/BOUNDARIES.md` - Detailed decision criteria for bd vs TodoWrite with examples
- `references/DEPENDENCIES.md` - Deep dive into dependency types and relationship patterns
- `references/WORKFLOWS.md` - Step-by-step workflows with checklists
- `references/ISSUE_CREATION.md` - When to ask vs create issues, quality guidelines
- `references/RESUMABILITY.md` - Making issues resumable across sessions

## CLI Reference

This skill intentionally does not duplicate CLI documentation. Instead:

- **Run `bd prime`** for AI-optimized workflow context
- **Run `bd <command> --help`** for specific command usage

This approach follows the official beads skill's [ADR-0001](https://github.com/steveyegge/beads/blob/main/claude-plugin/skills/beads/adr/0001-bd-prime-as-source-of-truth.md): using `bd prime` as the single source of truth for CLI commands.

## Why is This Useful?

The skill helps Claude understand:

1. **When to use beads** - Not every task needs bd. The skill teaches when bd helps vs when TodoWrite is better.

2. **How to structure issues** - Proper use of dependency types, issue metadata, and relationship patterns.

3. **Workflow patterns** - Proactive issue creation during discovery, status maintenance during execution.

4. **Compaction survival** - How to write notes that enable context recovery after conversation history is deleted.

## Usage

Once installed, Claude will automatically:

- Suggest creating bd issues for multi-session work
- Use appropriate dependency types when linking issues
- Maintain proper issue lifecycle (create → in_progress → close)
- Know when to use bd vs TodoWrite
- Run `bd prime` for CLI reference when needed

## License

MIT License
