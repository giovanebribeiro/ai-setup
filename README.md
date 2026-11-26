# ai-setup

A multi-harness AI configuration repository. Fork it, customise it for your stack, and symlink it into your harness of choice.

Supports **Claude Code**, **Cursor**, and **Opencode** from a single source of truth.

## Repository layout

```
ai-setup/
├── AGENTS.md           ← shared philosophy (Opencode entry point; included by CLAUDE.md)
├── CLAUDE.md           ← Claude Code entry point (@AGENTS.md + Claude-specific config)
├── .cursor/rules/      ← Cursor rules (.mdc, alwaysApply)
├── agents/             ← agent definitions (Claude Code)
├── commands/           ← slash commands (Claude Code)
├── contexts/           ← context files
├── docs/               ← documentation
│   └── ai-memory.md    ← ai-memory install, usage, and auth troubleshooting
├── notes/learned/      ← shared learned patterns
│   └── private/        ← gitignored; personal notes that stay local
├── rules/common/       ← shared rules (all harnesses)
├── scripts/            ← harness-agnostic shell scripts
└── skills/             ← skills (Claude Code)
```

## Installation

The repo lives outside harness config directories, and tracked files are **symlinked in** — so runtime files (credentials, cache, session data) never share a directory with git-tracked content.

```bash
# 1. Clone the repo wherever you keep dotfiles
git clone https://github.com/giovanebribeiro/ai-setup.git ~/workspace/ai-setup

# 2. Run the installer with the harness(es) you use
bash ~/workspace/ai-setup/install.sh --claude
bash ~/workspace/ai-setup/install.sh --cursor
bash ~/workspace/ai-setup/install.sh --opencode

# Or install multiple at once
bash ~/workspace/ai-setup/install.sh --claude --cursor --opencode
```

The installer symlinks each tracked item into the harness config directory. Anything already there gets backed up to `~/.ai-setup-backup/<timestamp>/` before being replaced.

**Git workflow after install:** always `cd ~/workspace/ai-setup` to commit and push — never run git from inside a harness config dir.

To remove the symlinks:

```bash
bash ~/workspace/ai-setup/uninstall.sh --claude
bash ~/workspace/ai-setup/uninstall.sh --cursor
bash ~/workspace/ai-setup/uninstall.sh --opencode
```

Runtime files are never touched.

## Harness-specific details

### Claude Code

- Entry point: `CLAUDE.md` (includes `AGENTS.md` via `@AGENTS.md`, then adds Claude-specific config)
- Agents: `agents/` → symlinked to `~/.claude/agents/`
- Commands: `commands/` → symlinked to `~/.claude/commands/`
- Rules: `rules/common/` → symlinked to `~/.claude/rules/common/`
- Skills: `skills/` → merged into `~/.claude/skills/`

### Cursor

- Entry point: `.cursor/rules/` → symlinked to `~/.cursor/rules/`
- Four rules files, all `alwaysApply: true`: `philosophy.mdc`, `agents.mdc`, `coding-style.mdc`, `git-workflow.mdc`

### Opencode

- Entry point: `AGENTS.md` → symlinked to `~/.opencode/AGENTS.md`
- Rules: `rules/common/` → symlinked to `~/.opencode/rules/`

## Customisation

This is a fork-and-customise setup. The defaults are opinionated — feel free to:

- Add or remove agents in `agents/`
- Add or remove commands in `commands/`
- Edit rules in `rules/common/` (changes propagate to all harnesses that read them)
- Add personal notes under `notes/learned/private/` (gitignored, never committed)

## Dependencies

| Dependency | Install |
|---|---|
| [serena](https://oraios.github.io/serena/02-usage/030_clients.html) | See link |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `claude mcp add --transport http mattpocock-skills https://skills.aihero.dev/mcp` |
| [ai-memory](https://github.com/akitaonrails/ai-memory) | See `docs/ai-memory.md` |

## ai-memory

See `docs/ai-memory.md` for install, basic usage, and auth troubleshooting.

## Skills via vercel-labs/skills

If you only need specific skills without the full symlink setup:

```bash
# List available skills
npx skills add giovanebribeiro/ai-setup --list

# Install a specific skill into the current project
npx skills add giovanebribeiro/ai-setup --skill initialize

# Install all skills globally
npx skills add giovanebribeiro/ai-setup -a claude-code -g -y
```
