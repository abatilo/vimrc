---
name: technical-writing
description: Write clear instructional and reference prose in the style of Simplified Technical English. Use when authoring or editing a runbook, procedure, step-by-step guide, README, API reference, configuration reference, troubleshooting guide, migration guide, release notes, architecture decision record, or a long pull request description, meaning anything a reader follows or looks facts up in. Covers imperative steps, condition-before-command order, consistent terminology, noun stacks, list structure, and warnings on destructive steps. Use diataxis-documentation to choose which document type to write, and humanizer for narrative or essay prose.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Technical writing

This is the sentence-level craft for a document a reader follows or looks
facts up in: a runbook, a procedure, a how-to guide, a README, an API or
configuration reference, a troubleshooting page, a migration guide, or a long
pull request description. rules/reporting.md already sets the register, and
everything in it applies here too. Use diataxis-documentation to decide which
kind of document you are writing; this file is about the sentences inside it.

Where guidance collides, the reader's task decides. On procedural and
reference text this file wins, including full contractions and deliberately
repeated terminology. On narrative prose, an essay, or anything meant to sound
like a person talking, humanizer wins and its voice guidance is the point.

## Sentences

Give each sentence one topic, and write the subject, the verb, and the object
out. A reader partway through a step cannot reconstruct an implied actor.
Prefer the active voice when the actor is known, and keep the passive for
descriptive text where the actor is unknown or beside the point: the scheduler
starts the service, but the token is rotated hourly.

Use "this" and other pronouns only where the thing they stand for is on the
page. A referent that lives in your context rather than in the document is the
most common defect in generated documentation.

## Words and terminology

Use one name for one thing, in every sentence, every heading, and every code
sample. Repeat the name rather than varying it for style, because two names
for one service read as two services. Where the repository already has a word
for something, use that word.

Prefer plain words to figurative or promotional ones, and unpack stacked nouns
into a phrase with a verb and a preposition. "Handle exhaustion of the
database connection pool" reads straight through, where "database connection
pool exhaustion handler" makes the reader parse before they can read. Write a
long term out in full the first time it appears, give its short form there,
and use the short form afterward. Introduce a specialized term before you lean
on it.

## Procedures

Write each instruction as a command. Give one instruction per sentence unless
the actions genuinely happen at once, so a reader who fails halfway through
still knows where they are. Put the condition before the command: when the
health check fails, restart the service. A reader who acts on the verb before
reaching the condition has already done the wrong thing.

Put the expected result immediately after the action that produces it, so each
step is something the reader can confirm rather than hope for. Number the
steps when the order matters. When you rewrite or summarize a procedure that
already exists, keep its sequence, because reordering it breaks it silently.

## Lists

Keep the items of a list at one logical level, and keep instructions and
description in separate lists, so a reader can tell at a glance which items
they are meant to perform. Turn a sentence that has grown a long series of
items or actions into a vertical list.

## Notes and destructive steps

A note carries supporting information. Anything the reader must do, must
avoid, or must satisfy belongs in the body of the procedure, because a note is
the first thing a reader skips.

Warn about a destructive step inside the step itself, in ordinary sentences
and ordinary capitalization. State the protective action first and then what
is lost without it: back up the database before you run the migration, because
the migration removes rows that do not match the new schema.
