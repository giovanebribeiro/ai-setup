# Git Workflow

## Commit message format

Conventional commits: `<type>(<scope>): <subject>`, where type =
feat|fix|docs|style|refactor|test|chore|perf. Subject: 70 chars max, imperative mood
("add" not "added"), no period.

- Small changes: one-line commit only.
- Complex changes: add a body explaining what/why (72-char lines), reference issues.
- Keep commits atomic (one logical change) and self-explanatory.
- Split into multiple commits if addressing different concerns.

## Tracker issue key in commit subject (opt-in)

When a commit implements tracked work, put the issue key in the scope:

```
feat(TEAM-123): add retry to card sync
```

This is opt-in, not mandatory — only for commits that went through issue creation. Most commits won't have one.
