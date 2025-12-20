# Your task

Look at recent history and use the bd-issue-tracking skill and create a series
of linked bd issues to cover the changes necessary. Use @agent-Plan with up to
10 parallel sub-agents for investigation of the changes necessary and then come
back and consolidate with the bd-issue-tracking skill for what all needs to be
created.

Every issue should end with explicit notes about running static analysis, tests
and e2e or integration tests. Use @agent-Explore to find how to run these if
you're not sure. Any failures amongst these should trigger you to create a
recursive meta bd issue with a title like: "Create plan for ZZZZ"

This meta issue should explicitly mention using @agent-Plan to create more bd
issues using the bd-issue-tracking skill, and these meta plan issues should be
P0 priority and the fixes should be P0 priority as well.

$ARGUMENTS
