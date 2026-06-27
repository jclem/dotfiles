# codex.nvim

Neovim IDE context provider for Codex CLI.

This plugin lets Codex request the same kind of local editor context that the VS Code extension provides: the active file, recent open file buffers, cursor or visual selection ranges, and selected text. It also includes an optional MCP bridge for diagnostics, references, and workspace symbol search backed by Neovim diagnostics and LSP.

## Install

Add this directory to your Neovim runtime path with your plugin manager. The plugin auto-starts by default when loaded.

To configure manually:

```lua
require("codex").setup({
  auto_start = true,
  codex_executable = "codex",
})
```

## Commands

- `:CodexIdeStart` starts the Codex IPC client and local router when needed.
- `:CodexIdeStop` stops the client, owned router, and MCP listener.
- `:CodexIdeStatus` prints the current socket and registration state.
- `:CodexIdeCopyMcpArgs` starts the MCP listener and copies Codex CLI flags for the LSP/MCP bridge.

## Protocol

See [docs/protocol.md](docs/protocol.md) for the full protocol reference derived from the inspected VSIX.
