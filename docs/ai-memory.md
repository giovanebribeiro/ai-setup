# ai-memory

[akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory) captures prompts and tool calls during AI sessions, converts them into wiki pages at session end, and surfaces a handoff at the start of the next session. It runs a local server that all configured harnesses share.

## Install

```bash
curl -fsSL https://github.com/akitaonrails/ai-memory/releases/latest/download/install.sh | sh
ai-memory setup
```

`setup` auto-detects installed harnesses. To target Claude Code specifically:

```bash
ai-memory setup --yes --agent claude-code
```

Or wire Claude Code manually after the binary install:

```bash
ai-memory install-mcp   --client claude-code --apply
ai-memory install-hooks --agent  claude-code --apply
```

**Plugin alternative (Claude Code only):**

```bash
claude plugin marketplace add akitaonrails/ai-memory
claude plugin install ai-memory@ai-memory
```

Restart Claude Code after either method to load the new MCP entry and hooks.

## Basic usage

Once installed, ai-memory works silently in the background:

- Hooks capture prompts and tool calls during the session.
- At session end, captures are converted into wiki pages on the local server.
- The next session opens with a handoff: "where did we leave off?"
- Query memory through natural conversation: "search memory for X" or "what do we know about Y?"
- Browse pages in the web UI: `http://127.0.0.1:49374/web`

Useful diagnostic commands:

```bash
ai-memory status    # server health + auth status
ai-memory doctor    # full diagnostic + remediation hints
ai-memory recent    # list newest memory pages
```

After upgrading, refresh routing in existing projects:

```bash
ai-memory install-instructions
```

## Auth

ai-memory uses a **bearer token**, not OAuth. On a fresh local install, auth is disabled by default; opt in with `ai-memory auth enable`.

`setup` mints a root token and stores it in `<data_dir>/auth-tokens/default` (owner-only file). Hooks and the MCP bridge read credentials from that file — the token is never printed and never written into harness configs.

For the web UI on a fresh install: any username, and the contents of `<data_dir>/auth-tokens/default` as the password.

For a **remote server**, set these in your shell rc:

```bash
export AI_MEMORY_SERVER_URL="http://<server-ip>:49374"
export AI_MEMORY_AUTH_TOKEN="<token>"
```

## Auth troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `ai-memory: command not found` | Binary not on PATH | Open a new terminal after install, or add the install dir to PATH |
| `GET /admin/status: 403 Forbidden: forbidden host` | `AI_MEMORY_ALLOWED_HOSTS` on the server doesn't include your client's address | Set `AI_MEMORY_ALLOWED_HOSTS` to the real IP/hostname on the server and restart |
| `401 Unauthorized` | Token on client differs from server's token | Use the same value on both sides; `generate-auth-token` creates a *new* random token each call, it does not fetch the existing one |
| `/healthz` returns unrecognized response | Another process owns port 49374 (Opencode's background service also defaults to this port) | Find which process owns the port; free it or change `bind` in `config.toml`, then re-run `setup`. For Opencode: `opencode service set port <free-port>` |
| `ai-memory doctor` flags a double-install conflict | Both `install-hooks` and the Claude plugin are active | Follow the doctor output to remove one copy |
