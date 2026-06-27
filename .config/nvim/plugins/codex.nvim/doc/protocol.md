# Codex IDE Integration Protocol

This reference documents the local Codex IDE integration protocols and the compatible surface implemented by this Neovim plugin.

The integration uses three related protocols:

- Codex IDE IPC: Codex CLI requests active editor context such as open files and selections.
- LSP/MCP bridge: Codex CLI calls editor-backed tools for diagnostics, references, and symbols.
- Desktop app bridge: the ChatGPT macOS app reads and mutates visible editor buffers.

## Codex IDE IPC

### Socket path

On Unix-like systems the router socket path is:

```text
${os.tmpdir()}/codex-ipc/ipc-${uid}.sock
```

If the process has no UID or UID is `0`, the router uses:

```text
${os.tmpdir()}/codex-ipc/ipc.sock
```

On Windows the path is:

```text
\\.\pipe\codex-ipc
```

The Neovim implementation currently supports Unix-like systems.

### Frame format

Every IPC message is one binary frame:

```text
uint32_le payload_byte_length
utf8_json_payload
```

The maximum accepted frame size is `256 * 1024 * 1024` bytes. A zero-length frame is invalid.

### Message envelope

Requests:

```json
{
  "type": "request",
  "requestId": "uuid",
  "sourceClientId": "client-id",
  "version": 1,
  "method": "ide-context",
  "params": {},
  "targetClientId": "optional-client-id",
  "timeoutMs": 5000
}
```

Responses:

```json
{
  "type": "response",
  "requestId": "uuid",
  "resultType": "success",
  "method": "ide-context",
  "handledByClientId": "client-id",
  "result": {}
}
```

Error responses use:

```json
{
  "type": "response",
  "requestId": "uuid",
  "resultType": "error",
  "error": "no-client-found"
}
```

Broadcasts:

```json
{
  "type": "broadcast",
  "method": "client-status-changed",
  "sourceClientId": "client-id",
  "version": 1,
  "params": {}
}
```

### Initialisation

Every client first sends:

```json
{
  "type": "request",
  "requestId": "uuid",
  "sourceClientId": "initializing-client",
  "version": 1,
  "method": "initialize",
  "params": {
    "clientType": "neovim"
  }
}
```

The router replies:

```json
{
  "type": "response",
  "requestId": "uuid",
  "resultType": "success",
  "method": "initialize",
  "handledByClientId": "assigned-client-id",
  "result": {
    "clientId": "assigned-client-id"
  }
}
```

### Discovery

When a request does not name `targetClientId`, the router asks other clients whether they can handle it:

```json
{
  "type": "client-discovery-request",
  "requestId": "uuid",
  "request": {
    "type": "request",
    "requestId": "original-request-id",
    "method": "ide-context",
    "version": 1,
    "params": {}
  }
}
```

A client replies:

```json
{
  "type": "client-discovery-response",
  "requestId": "uuid",
  "response": {
    "canHandle": true
  }
}
```

The router forwards the original request to the first client that returns `canHandle: true`.

### `ide-context`

Codex sends:

```json
{
  "workspaceRoot": "/absolute/project/root"
}
```

An IDE client accepts the request only when `workspaceRoot` is inside one of its workspace folders. This plugin accepts it when the root matches a configured workspace root, Neovim's current working directory, an LSP workspace folder, or an open file buffer.

The response shape is:

```json
{
  "ideContext": {
    "activeFile": {
      "label": "init.lua",
      "path": "lua/plugin/init.lua",
      "fsPath": "/absolute/project/lua/plugin/init.lua",
      "selection": {
        "start": { "line": 10, "character": 2 },
        "end": { "line": 12, "character": 8 },
        "anchor": { "line": 10, "character": 2 },
        "active": { "line": 12, "character": 8 }
      },
      "activeSelectionContent": "selected text",
      "selections": [
        {
          "start": { "line": 10, "character": 2 },
          "end": { "line": 12, "character": 8 }
        }
      ]
    },
    "openTabs": [
      {
        "label": "init.lua",
        "path": "lua/plugin/init.lua",
        "fsPath": "/absolute/project/lua/plugin/init.lua"
      }
    ]
  }
}
```

Positions are zero-based. `activeSelectionContent` is empty when there is no active visual selection. The reference implementation caps selected text at 200,000 bytes; this plugin uses the same default.

## LSP/MCP Bridge

### Topology

The IDE integration creates a Unix-domain socket and configures Codex CLI with an MCP server named `codex-lsp-mcp`:

```toml
mcp_servers.codex-lsp-mcp = {
  command = "codex",
  args = ["stdio-to-uds", "/path/to/lsp-mcp.sock"]
}
```

`codex stdio-to-uds` bridges MCP stdio JSON lines to the Unix socket. The socket itself carries one JSON-RPC message per line.

This plugin exposes `:CodexIdeCopyMcpArgs`, which copies a compatible `codex --config ...` command line.

### MCP initialisation

Codex sends the normal MCP `initialize` request. The server responds with tools capability:

```json
{
  "protocolVersion": "2025-06-18",
  "capabilities": {
    "tools": {
      "listChanged": false
    }
  },
  "serverInfo": {
    "name": "nvim-codex-lsp-mcp-server",
    "version": "0.1.0"
  }
}
```

### Tools

#### `vscodeDiagnostics`

Input:

```json
{
  "maxDiagnostics": 50,
  "file": "optional/path",
  "source": "optional-source-or-array",
  "code": "optional-code-or-array",
  "includeNonWorkspaceDiagnostics": false,
  "minSeverity": "information"
}
```

Output:

```json
{
  "diagnostics": [
    {
      "filePath": "/absolute/file",
      "relativePath": "relative/file",
      "range": {
        "start": { "line": 0, "character": 0 },
        "end": { "line": 0, "character": 10 }
      },
      "severity": "error",
      "source": "lua_ls",
      "code": "optional-code",
      "message": "diagnostic message"
    }
  ],
  "returnedDiagnostics": 1,
  "totalDiagnosticsAfterFiltering": 1,
  "limit": 50,
  "truncated": false,
  "summary": []
}
```

Severity values are `error`, `warning`, `information`, and `hint`.

#### `vscodeReferences`

Input:

```json
{
  "file": "/absolute/file",
  "position": { "line": 0, "character": 0 },
  "includeDeclaration": true
}
```

Output:

```json
{
  "references": [
    {
      "filePath": "/absolute/file",
      "relativePath": "relative/file",
      "range": {
        "start": { "line": 0, "character": 0 },
        "end": { "line": 0, "character": 5 }
      }
    }
  ],
  "returnedReferences": 1,
  "summary": []
}
```

VS Code uses `vscode.executeReferenceProvider`; this plugin uses Neovim LSP `textDocument/references`.

#### `vscodeWorkspaceSymbols`

Input:

```json
{
  "query": "SymbolName",
  "maxSymbols": 100
}
```

Output:

```json
{
  "symbols": [
    {
      "name": "SymbolName",
      "kind": "function",
      "containerName": "Module",
      "location": {
        "filePath": "/absolute/file",
        "relativePath": "relative/file",
        "range": {
          "start": { "line": 0, "character": 0 },
          "end": { "line": 0, "character": 5 }
        }
      }
    }
  ],
  "returnedSymbols": 1,
  "totalSymbols": 1,
  "limit": 100,
  "truncated": false,
  "summary": []
}
```

VS Code uses `vscode.executeWorkspaceSymbolProvider`; this plugin uses Neovim LSP `workspace/symbol`.

## Desktop App Bridge

The VS Code integration also registers a ChatGPT desktop bridge for "Work with VS Code". This is not the same path as Codex CLI `/ide`.

The bridge advertises these commands:

| Command | Category | Description |
| --- | --- | --- |
| `ping` | query | Returns app and extension identity. |
| `content` | query | Returns visible editor contents and selected text. |
| `selections` | query | Returns visible editor selections only. |
| `reload` | query | Reloads bridge state. |
| `markForReload` | query post | Marks the app registration for reload. |
| `removeHighlights` | mutation | Removes editor highlights. |
| `highlightLines` | mutation | Highlights whole lines. |
| `highlight` | mutation | Highlights a range. |
| `setContent` | mutation | Replaces an editor buffer's full content. |
| `replaceSelection` | mutation | Replaces the current selection. |

The desktop bridge's content response for each visible editor has this shape:

```json
{
  "id": "/absolute/file",
  "content": "full buffer text",
  "filename": "/absolute/file",
  "selectedText": "selected text or null",
  "selectionRange": { "location": 12, "length": 5 },
  "selectionLine": 10
}
```

The desktop bridge is not implemented by this plugin in v1. The Neovim implementation focuses on Codex CLI IDE context and the optional LSP/MCP tools.

## Compatibility Notes

- The reference implementation and this plugin both use zero-based line and character positions in protocol payloads.
- VS Code reports character positions using its document model; Neovim reports byte-indexed columns for buffer APIs. This can differ for multi-byte text.
- The Neovim router implements the routing behaviour needed for `initialize`, discovery, forwarded requests, responses, and `client-status-changed` broadcasts.
- Windows named pipe support is documented but not implemented in this plugin.
