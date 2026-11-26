@AGENTS.md

# Claude Code — Harness-Specific Configuration

## Commands

Located in `~/.claude/commands`

| Command | Description |
|---------|-------------|
| gha | Analyze GitHub Actions failures and identify root causes |
| refactor-clean | Safely identify and remove dead code with test verification at every step |
| skill-health | Show skill portfolio health dashboard with charts and analytics |
| tdd | Enforce TDD workflow — write tests first, red-green-refactor |
| update-codemaps | Analyze the codebase structure and generate token-lean architecture documentation |
| update-docs | Sync documentation with the codebase, generating from source-of-truth files |
| verify | Run comprehensive verification on current codebase state |

## Rules

Located in `~/.claude/rules/`

| Rule File | Contents |
|-----------|----------|
| agents.md | Agent orchestration, when to use which agent |
| coding-style.md | Immutability, file organization, error handling |
| git-workflow.md | Commit format, PR workflow |

## Agents

Located in `~/.claude/agents/`

| Agent | Purpose |
|-------|---------|
| manager | Top-level orchestrator, decomposes requests and dispatches to specialists |
| architect | System design and architecture |
| code-reviewer | Code review for quality/security |
| lang-reviewer | Language-specific review for Go, Java, Python, Rust |
| build-resolver | Build/lint/compilation fixes — auto-detects language |
| security-reviewer | Security vulnerability analysis |

## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: one `GLOSSARY.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
