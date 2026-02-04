---
name: socratic
description: Deep collaborative debate and research through exhaustive co-interview between Claude and Codex. Use when user wants extremely thorough analysis, needs to explore a problem from every angle, wants creative/unconventional questioning, says "get socratic", "debate this", "deep dive", "exhaustive analysis", "think through everything", "challenge all assumptions", or needs rigorous exploration before major decisions.
argument-hint: "[topic or question to explore]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - WebSearch
  - WebFetch
---

# Socratic Inquiry

An exhaustive, multi-round co-interview between you and Codex MCP. Both sides question each other relentlessly—not to win, but to expose contradictions, surface hidden assumptions, and reach genuine understanding. The goal is **aporia**: productive puzzlement that reveals what you don't actually know.

## Philosophy

This is not normal planning. This is **adversarial collaboration**—two minds trying to break each other's thinking, find blind spots, surface hidden assumptions, and discover what neither would find alone.

- **Go weird.** Ask questions the user would never think to ask.
- **Be uncomfortable.** Probe the parts people avoid.
- **Think laterally.** What adjacent domains have relevant wisdom?
- **Invert everything.** What if the opposite were true?
- **Find the unstated.** What's being assumed without saying?

## The Protocol

### Phase 1: Grounding (Solo)

Before engaging Codex, ground yourself in the environment:

1. **Read the conversation history** to understand the topic deeply
2. **Explore the codebase** if relevant—gather concrete facts
3. **Search the web** if external context would help
4. **Formulate your initial position** with explicit assumptions

Do not ask Codex obvious questions you could answer yourself.

### Phase 2: Opening Salvo

Start the Codex thread with `mcp__codex__codex`. Your opening should:

1. **State the topic** clearly
2. **Share your initial position** with reasoning
3. **List your assumptions** explicitly
4. **Ask your first deep questions**—at least 3, all non-obvious

Example opening questions (adapt to topic):
- "What's the failure mode nobody talks about?"
- "If this succeeds wildly, what new problems emerge?"
- "What would make a smart person bet against this approach?"
- "What's the assumption here that will look obviously wrong in 5 years?"
- "Who loses if this works? What might they do?"

### Phase 3: The Debate Rounds

Continue with `mcp__codex__codex-reply`. Each round must:

1. **Respond substantively** to Codex's questions and challenges
2. **Update your position** based on new insights (or defend it with new arguments)
3. **Ask new questions** that go deeper or wider

**Question Categories to Explore** (hit all of these across rounds):

#### Technical/Implementation
- What's the hardest part nobody's mentioned?
- Where are the hidden dependencies?
- What breaks at 10x scale? 100x? 1000x?
- What's the debugging nightmare scenario?
- Which part will we regret not abstracting? Which abstraction will we regret?

#### Failure Modes & Edge Cases
- How does this fail silently?
- What's the "2am production incident" scenario?
- What happens when assumptions don't hold?
- What's the recovery path when this goes wrong?
- What external changes could break this completely?

#### Human & Organizational
- Who needs to understand this for it to work?
- What's the bus factor? What if key people leave?
- How does this interact with team incentives?
- What will be hard to change later due to organizational inertia?
- Who will resist this and why might they be right?

#### Strategic & Meta
- What are we optimizing for? What are we sacrificing?
- What's the opportunity cost of doing this?
- What problem are we actually solving? Is that the right problem?
- If we had to abandon this approach entirely, what would we do instead?
- What would we do if we had half the time? Twice the time?

#### Weird & Lateral
- What would a completely different industry do here?
- What's the "crazy" approach that might actually work?
- What if we did nothing? What happens naturally?
- What's the contrarian view and why might it be right?
- What question are we afraid to ask?
- What's the elephant in the room?
- If this were a disaster in hindsight, what would the post-mortem say?

### Phase 4: Convergence Check

At the end of each round, explicitly ask Codex:

> "Have we exhausted this topic? What angles remain unexplored? What questions haven't we asked that we should? Are you satisfied we've gone deep enough, or should we continue?"

Codex should respond honestly about whether more exploration is needed. You should also assess whether you have unexplored angles.

**Continue debating until both sides agree the topic is exhausted.**

There is no round limit. If the topic warrants 20 rounds, do 20 rounds. Thoroughness over speed.

### Phase 5: Synthesis

Only after mutual agreement that exploration is complete, synthesize:

1. **Key insights** that emerged from the debate
2. **Shifted positions** where your thinking changed
3. **Unresolved tensions** that remain genuinely uncertain
4. **Concrete recommendations** if applicable
5. **Questions for the user** that only they can answer

## Continuation Criteria

Keep going if ANY of these are true:
- Either side has unexplored angles they want to pursue
- A question category hasn't been adequately covered
- New threads emerged that weren't followed to completion
- Either side feels the topic hasn't been fully stress-tested
- There's a nagging feeling something was missed

## Stopping Conditions

Stop ONLY when:
- Both sides explicitly agree the topic is exhausted
- All question categories have been explored thoroughly
- Neither side can generate genuinely new angles
- Any remaining uncertainty requires user input to resolve

Do NOT stop just because:
- You've reached agreement (agreement might mean you're both wrong—probe it)
- It feels "good enough" (push past comfortable)
- The obvious points have been covered (the obvious points are the easy ones)
- It's been "a lot" of rounds (there is no such thing as too many rounds)
- You're tired of the topic (the user invoked this skill because they want exhaustive)

## Output Format

After the debate concludes, present to the user:

```markdown
# Socratic Inquiry: [Topic]

## Summary
[2-3 sentence overview of what was explored]

## Key Insights
- [Insight 1]: [Brief explanation]
- [Insight 2]: [Brief explanation]
- ...

## Position Shifts
- **Started thinking:** [initial view]
- **Now thinking:** [evolved view]
- **Because:** [what changed it]

## Unresolved Tensions
- [Tension 1]: [Why it's genuinely uncertain]
- ...

## Recommendations
[If applicable—concrete next steps]

## Questions Only You Can Answer
- [Question 1]
- [Question 2]
- ...

## Full Debate Transcript
[Include the full back-and-forth for reference]
```

## Anti-Patterns to Avoid

- **Softball questions**: "What do you think about X?" → Ask "What's wrong with X?"
- **Premature agreement**: Don't agree just to be agreeable
- **Surface-level coverage**: Don't check boxes, go deep on fewer things
- **Obvious questions**: If you could Google it, don't ask Codex
- **Staying comfortable**: If it doesn't feel a little uncomfortable, push harder
- **Confirmation seeking**: Don't look for validation, look for holes
