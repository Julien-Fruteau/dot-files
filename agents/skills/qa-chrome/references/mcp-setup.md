# Chrome DevTools MCP setup, per agent

Once per machine. It changes the user's agent configuration, so propose the
command and let the user run it — then the MCP tools only appear in the **next**
session. Use the section for the agent you are running in; if the user drives
several agents, offer the others too.

Every variant registers the same server, attached to the QA Chrome on port 9222
(see [`browser.md`](browser.md)) rather than launching its own headless browser:

```
npx -y chrome-devtools-mcp@latest --browserUrl=http://127.0.0.1:9222 --no-usage-statistics --no-performance-crux
```

## Claude Code

Check: `claude mcp list | grep chrome-devtools`. Install:

```bash
claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest --browserUrl=http://127.0.0.1:9222 --no-usage-statistics --no-performance-crux
```

## Codex

Check: `codex mcp list | grep chrome-devtools`. Install:

```bash
codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest --browserUrl=http://127.0.0.1:9222 --no-usage-statistics --no-performance-crux
```

This writes a `[mcp_servers.chrome-devtools]` table to `~/.codex/config.toml`.

## pi

pi has no built-in MCP support; it goes through the `pi-mcp-adapter` extension.
Check: `pi list` shows `pi-mcp-adapter`, and `~/.pi/agent/mcp.json` has a
`chrome-devtools` entry. Install the extension (if the user manages pi packages
declaratively, add it to that list instead):

```bash
pi install npm:pi-mcp-adapter
```

then add the server to `~/.pi/agent/mcp.json` (merge with existing entries):

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--browserUrl=http://127.0.0.1:9222", "--no-usage-statistics", "--no-performance-crux"]
    }
  }
}
```

By default the adapter exposes the server behind a single proxy tool, started on
first use; the tool names in `browser.md` are passed through it.

## Any other agent

Register the command above as a stdio MCP server named `chrome-devtools` in the
agent's user-level MCP configuration.
