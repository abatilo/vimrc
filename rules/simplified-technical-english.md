# Simplified Technical English

Use these rules for technical documentation, runbooks, code comments, API
documentation, pull-request descriptions, troubleshooting text, and technical
user-facing summaries.

The goal is clear, accurate writing for a reader who did not watch the work
happen. Preserve technical meaning before you simplify the language.

## Communication style

- Lead with the outcome. The first sentence must say what happened, what
  changed, or what you found.
- Write the final message as a fresh explanation for the reader, not as a
  continuation of your internal work.
- Use complete sentences and familiar words. Prefer clear writing over
  compressed writing.
- Include details only when they change what the reader understands or does
  next.
- Introduce specialized terms before you use them repeatedly.
- Replace arrow chains, stacked labels, and dense shorthand with
  plain-language clauses.
- State uncertainty directly. Distinguish verified results from assumptions
  and unfinished work.

Example:

> The request timeout is fixed. The client now retries one time after a
> transient gateway error, and the integration test passes.

Avoid:

> Fixed: timeout → retry path → green.

## Protect technical meaning

- Preserve requirements, limits, units, identifiers, commands, paths, API
  names, code symbols, UI labels, log messages, and quoted text exactly.
- Preserve the sequence of operations.
- Preserve the difference between a requirement, recommendation, permission,
  and possibility.
- Use the project glossary and repository terminology. Use one term for one
  item throughout the text.
- Identify an ambiguity instead of guessing about missing facts, causes,
  hazards, or acceptance criteria.
- Use American English spelling unless the project requires another standard.

## Words and terminology

- Prefer common approved words over synonyms, jargon, slang, regional terms,
  or figurative language.
- Use domain terms as technical nouns or technical verbs when the project or
  subject field requires them.
- Keep a multi-word noun to three words when possible.
- Write an official long term in full at first use. Then use its defined
  short form or approved abbreviation.
- Use the same noun for the same component, service, state, and result.
- Use a word only with the meaning and part of speech intended in the
  sentence.
- Preserve exact product names, code identifiers, protocol tokens, and quoted
  interface text.

Example:

> Calibrate the resistance of the runway light connection.

Avoid:

> Perform runway light connection resistance calibration.

## Sentences

- Give each sentence one primary topic.
- Write the subject, verb, and object explicitly.
- Use articles such as the, a, and an when grammar requires them.
- Use this or a pronoun only when its referent is unmistakable.
- Write contractions in full: use do not, cannot, and it is.
- Use a new sentence when a semicolon would be necessary.
- Put a necessary condition before the action.
- Use a vertical list when a sentence contains many items or actions.

Example:

> When the health check fails, restart the service.

Avoid:

> Restart the service when the health check fails.

## Verbs and voice

- Use a direct verb to describe an action.
- Use active voice when the agent is known.
- Use passive voice in descriptive text only when the agent is unknown or
  technically irrelevant.
- Prefer simple present, simple past, simple future, infinitive, and
  imperative forms.
- Replace perfect, progressive, and complex auxiliary constructions when a
  simple form preserves the meaning.
- Use an -ing form only when it is an established technical noun or modifier.
- Do not convert a technical noun into a verb unless the domain uses it as a
  technical verb.

Example:

> The scheduler starts the service.

Avoid:

> The service is started by the scheduler.

Example:

> Apply grease to the fasteners.

Avoid:

> Grease the fasteners.

## Procedures

- Write each instruction in the imperative form.
- Use no more than 20 words in each procedural sentence.
- Give one instruction per sentence unless the actions occur at the same
  time.
- Put a prerequisite or condition first, followed by a comma and the command.
- Put a limit, expected result, or acceptance criterion directly after its
  related action.
- Number steps when order matters.

Example:

> 1. Stop the service.
> 2. Save the configuration file.
> 3. Restart the service.

Avoid:

> Stop the service, save the configuration file, and restart the service.

## Descriptions and summaries

- Give information gradually, from the primary result to supporting detail.
- Use no more than 25 words in each descriptive sentence.
- Give each paragraph one topic.
- Use no more than six sentences in a paragraph.
- Repeat key terms when repetition prevents ambiguity. Do not vary
  terminology for style.
- Use connecting words such as and, but, then, thus, and as a result when
  they clarify the relationship between sentences.

Example:

> The cache stores completed responses. The request handler checks this cache
> before it calls the model. As a result, repeated requests complete faster.

## Lists

- Put a colon before a vertical list.
- Keep all list items at the same logical level.
- Start each item with an uppercase letter.
- Use a period after a full sentence.
- Do not use a comma or semicolon at the end of a list item.
- Put a period after the final item.
- Do not mix instructions and descriptive statements in the same list.

## Notes and safety instructions

- Use a note only for supporting information. A note must not contain an
  instruction, requirement, limit, result, or safety precaution.
- Use WARNING for a risk of injury or death.
- Use CAUTION for a risk of damage to equipment, software, data, or other
  property.
- Start a safety instruction with the command or condition. Follow it with
  the hazard and possible result.

Example:

> CAUTION: BACK UP THE DATABASE BEFORE YOU RUN THE MIGRATION. THE MIGRATION
> CAN REMOVE DATA THAT DOES NOT MATCH THE NEW SCHEMA.

## Code comments and technical summaries

- Explain what the code does or why a constraint exists.
- Preserve symbol names exactly.
- Do not restate syntax that is already obvious from the code.
- State test results and progress only when tool output or repository
  evidence verifies them.
- When work is incomplete, say what remains and why.

Example:

```go
// Keep the previous token until the peer confirms the rotation.
```

Avoid:

```go
// Set oldToken because we need it below.
```

## Final check

Before you finish, verify that:

- The first sentence gives the outcome.
- The technical meaning and normative force are unchanged.
- Terms, identifiers, units, commands, and quoted text remain exact.
- Each sentence has one clear topic and an explicit action.
- Procedures use imperative verbs and stay within 20 words per sentence.
- Descriptions stay within 25 words per sentence.
- Conditions come before commands.
- Active voice is used when the agent is known.
- Pronouns and this have one clear referent.
- Notes contain no required action, limit, result, or safety information.
- Safety instructions state both the preventive action and the possible
  result.
- The final message uses complete sentences and no working shorthand.
