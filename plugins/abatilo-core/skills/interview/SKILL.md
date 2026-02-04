---
name: interview
description: Interview users in-depth about their plans using probing, non-obvious questions. Use when user says "/interview", "interview me", "question my plan", "probe my idea", "challenge my assumptions", or wants deep exploration of a plan before implementation.
allowed-tools:
  - AskUserQuestion
  - Read
---

# Plan Interview Skill

This skill helps you thoroughly explore and stress-test plans through in-depth questioning.

## When to Use This Skill

Use this skill when:
- A user has outlined a plan and wants it challenged
- You need to uncover hidden assumptions or risks
- A plan needs to be fleshed out before implementation
- The user wants to think through edge cases and tradeoffs

## Process

1. **Review Context**
   - Read the entire conversation to understand the plan being discussed
   - Identify the core goals, constraints, and proposed approach

2. **Interview In-Depth**
   - Use the AskUserQuestion tool to probe the plan
   - Ask about anything relevant: technical implementation, UI/UX, concerns, tradeoffs, edge cases, assumptions, risks, dependencies
   - Make questions non-obvious - probe deeper into things they might not have considered
   - Challenge assumptions directly
   - Ask about the hard parts

3. **Continue Until Complete**
   - Keep interviewing until the plan is fully fleshed out
   - Don't stop after surface-level questions
   - Dig into specifics and corner cases

4. **Summarize**
   - Once complete, re-iterate the full plan incorporating everything discussed
   - Highlight key decisions made and risks identified

## Question Categories

Consider probing these areas:
- **Technical**: Architecture, scalability, performance, security
- **UX**: User flows, error states, edge cases, accessibility
- **Dependencies**: External services, libraries, team coordination
- **Risks**: What could go wrong? What's the fallback?
- **Assumptions**: What are we taking for granted?
- **Scope**: What's in/out? Where are the boundaries?
- **Maintenance**: How will this evolve? Who maintains it?

## Key Principles

- **Be thorough** - Don't accept surface-level answers
- **Challenge assumptions** - Question things that seem "obvious"
- **Explore failure modes** - What happens when things go wrong?
- **Stay curious** - Follow interesting threads deeper
