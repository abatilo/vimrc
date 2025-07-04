## Context

The user has requested deep exploration and investigation for the following topic:
<topic>
$ARGUMENTS
</topic>

This command focuses on discovery, understanding, and answering questions about
the codebase or topic. Unlike task execution, our goal is to thoroughly
investigate, document findings, and provide comprehensive answers.

### CRUMBS

Create a CRUMBS/ directory at the root of the repository. If it already exists,
clear all files.  We will use this as a workspace to document our discoveries,
insights, and answers as we explore.

### Phases

Since this is a discovery-focused command, we approach this systematically
through research and documentation phases.

<phases>

<initial_exploration_phase>
  Begin with broad exploration to understand the scope and context of the investigation. Use search tools extensively to map out relevant areas of the codebase. Document initial findings and create a high-level overview in CRUMBS/01_overview.md. This should include:
  - Key components related to the topic
  - File structure and organization
  - Initial observations and patterns
</initial_exploration_phase>

<deep_investigation_phase>
  Conduct targeted deep dives into specific areas identified during initial exploration. For each area of interest:
  - Create numbered investigation files (CRUMBS/02_investigation_[topic].md)
  - Document code flows, relationships, and dependencies
  - Note any design patterns or architectural decisions
  - Identify potential edge cases or interesting behaviors
  - Use deepwiki mcp for any third-party libraries involved
</deep_investigation_phase>

<question_formulation_phase>
  Based on discoveries, formulate and document key questions that arise:
  - Create CRUMBS/03_questions.md
  - List explicit questions from the user
  - Add implicit questions that emerged during investigation
  - Identify areas requiring further clarification
  - Prioritize questions by importance and relevance
</question_formulation_phase>

<answer_synthesis_phase>
  Systematically answer each question with evidence from the codebase:
  - Create CRUMBS/04_answers.md
  - Provide detailed answers with code references (file_path:line_number)
  - Include relevant code snippets and examples
  - Explain the "why" behind implementations
  - Note any uncertainties or areas needing more investigation
</answer_synthesis_phase>

<comprehensive_report_phase>
  Create a final comprehensive report that:
  - Summarizes all findings in CRUMBS/05_final_report.md
  - Provides clear, digestible answers to the original questions
  - Includes visual diagrams or flowcharts if helpful
  - Highlights key insights and discoveries
  - Suggests areas for potential follow-up investigation
</comprehensive_report_phase>

</phases>

### Key Principles

1. **Thorough Investigation**: Leave no stone unturned. Read extensively to build complete understanding.
2. **Documentation First**: Document every finding, no matter how small, in CRUMBS.
3. **Evidence-Based**: Support all conclusions with specific code references.
4. **Question Everything**: Don't assume - verify and understand the "why" behind implementations.
5. **Clarity**: Present findings in clear, accessible language with examples.
