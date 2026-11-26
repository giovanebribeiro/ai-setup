# Agent Orchestration

## Agent roster

| Agent | When to use |
|---|---|
| manager | Decompose complex multi-step/multi-domain user requests, dispatch to specialists. |
| architect | System design, scalability, architectural trade-offs. Mandatory first step in any `manager` plan. |
| code-reviewer | General code review for quality/security/maintainability. Use after any code change. |
| security-reviewer | Vulnerability detection after code touching input, auth, endpoints, secrets. |
| lang-reviewer | Language-specific code review for Go, Java, Python, and Rust — auto-detects from changed files. |
| build-resolver | Fix build/vet/lint/compilation failures for Go, Java/Maven/Gradle, and Rust/Cargo — auto-detects from build files. |
| doc-updater | Update docs/codemaps. Mandatory last step in any `manager` plan. |

## Agent vs skill

**Agent** = own context window, tool access, autonomy; does multi-step judgment where the path isn't predetermined.
**Skill** = reference knowledge or fixed procedure loaded into the caller's context; no autonomy, caller already decided to act.

When adding new capability: if it requires branching judgment across multiple steps, it's an agent. If it's know-how or a checklist consumed by an already-deciding caller, it's a skill.

## Skill<->agent frontmatter convention

Skill files may declare `agents: ["name", ...]` (or `agents: ["*"]` for any agent) to indicate intended callers.
Agent files may declare `skills: ["name", ...]` to indicate skills that agent is expected to invoke via the Skill tool.

**Limitation:** this is a documentation/prompt convention, not access control. The Skill tool resolves by name only and does not check caller identity. Treat these fields as a discoverability aid for humans and tooling (e.g. `skill-health`), not a security boundary.

## Invoking manager

Manager cannot invoke architect on its own. Whoever invokes `manager` must:

1. Invoke `architect` first with the user's request.
2. Invoke `manager` second, including architect's output in the prompt.
3. Execute each step of manager's returned dispatch table in order.

If `manager` is invoked without an architect design already in the prompt, it will refuse to fabricate a plan and instead ask its caller to run step 1 first.

## Manager plan sequencing rules

1. `architect` always runs first — mandatory plan composition/validation step, never skipped.
2. `build-resolver` runs before reviewers touching the same code.
3. `lang-reviewer` and `code-reviewer` run in parallel when they don't conflict on the same files.
4. `security-reviewer` is conditional, not unconditional — but the condition is a floor: **any** step touching auth, secrets/credentials, user input parsing, deserialization, or API endpoints MUST get a `security-reviewer` pass, in parallel with `lang-reviewer` covering the same files.
5. `doc-updater` always runs last — mandatory documentation step, included even if the user's request never mentioned documentation.
