local config = require("codex.config")
local util = require("codex.util")

local M = {}

local state = {
  server = nil,
  socket_path = nil,
  socket_dir = nil,
  clients = {},
}

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warning",
  [vim.diagnostic.severity.INFO] = "information",
  [vim.diagnostic.severity.HINT] = "hint",
}

local severity_rank = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  information = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

local symbol_kinds = {
  "file",
  "module",
  "namespace",
  "package",
  "class",
  "method",
  "property",
  "field",
  "constructor",
  "enum",
  "interface",
  "function",
  "variable",
  "constant",
  "string",
  "number",
  "boolean",
  "array",
  "object",
  "key",
  "null",
  "enumMember",
  "struct",
  "event",
  "operator",
  "typeParameter",
}

local function text_response(id, structured)
  return {
    jsonrpc = "2.0",
    id = id,
    result = {
      content = {
        { type = "text", text = table.concat(structured.summary or {}, "\n") },
      },
      structuredContent = structured,
    },
  }
end

local function error_response(id, code, message)
  return {
    jsonrpc = "2.0",
    id = id,
    error = { code = code or -32000, message = message },
  }
end

local function buffer_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= "" and util.normalize(name) or nil
end

local function resolve_file(file)
  if not file or file == "" then
    return nil
  end
  if vim.startswith(file, "file://") then
    return vim.uri_to_fname(file)
  end
  if vim.fn.fnamemodify(file, ":p") == file then
    return util.normalize(file)
  end

  for _, root in ipairs(config.workspace_roots()) do
    local candidate = util.joinpath(root, file)
    if vim.fn.filereadable(candidate) == 1 then
      return util.normalize(candidate)
    end
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local path = buffer_path(bufnr)
    if path and (path:sub(-#file) == file or util.relative_path(path, vim.fn.getcwd()) == file) then
      return path
    end
  end

  return nil
end

local function relative_path(path)
  for _, root in ipairs(config.workspace_roots()) do
    if util.path_contains(root, path) then
      return util.relative_path(path, root)
    end
  end
  return nil
end

local function diagnostic_matches(item, opts)
  local diagnostic = item.diagnostic
  if opts.min_severity and diagnostic.severity > opts.min_severity then
    return false
  end
  if opts.file and item.path ~= opts.file then
    return false
  end
  if opts.sources and not opts.sources[diagnostic.source or ""] then
    return false
  end
  if opts.codes then
    local code = diagnostic.code and tostring(diagnostic.code) or ""
    if not opts.codes[code] then
      return false
    end
  end
  if not opts.include_non_workspace and not relative_path(item.path) then
    return false
  end
  return true
end

local function list_diagnostics(args)
  args = args or {}
  local limit = math.min(tonumber(args.maxDiagnostics) or 50, 1000)
  local min_severity = severity_rank[args.minSeverity or "information"] or severity_rank.information
  local resolved_file = args.file and resolve_file(args.file) or nil
  local sources = args.source and {}
  if type(args.source) == "string" then
    sources[args.source] = true
  elseif type(args.source) == "table" then
    for _, source in ipairs(args.source) do
      sources[source] = true
    end
  else
    sources = nil
  end

  local codes = args.code and {}
  if type(args.code) == "string" then
    codes[args.code] = true
  elseif type(args.code) == "table" then
    for _, code in ipairs(args.code) do
      codes[tostring(code)] = true
    end
  else
    codes = nil
  end

  local all = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local path = buffer_path(bufnr)
    if path then
      for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
        table.insert(all, { path = path, diagnostic = diagnostic })
      end
    end
  end

  local filtered = {}
  for _, item in ipairs(all) do
    if diagnostic_matches(item, {
      min_severity = min_severity,
      file = resolved_file,
      sources = sources,
      codes = codes,
      include_non_workspace = args.includeNonWorkspaceDiagnostics == true or resolved_file ~= nil,
    }) then
      table.insert(filtered, item)
    end
  end

  local diagnostics = {}
  local summary = {}
  for index, item in ipairs(filtered) do
    if index > limit then
      break
    end
    local diagnostic = item.diagnostic
    local rel = relative_path(item.path)
    local severity = severity_names[diagnostic.severity] or "error"
    local entry = {
      filePath = item.path,
      relativePath = rel or vim.NIL,
      range = {
        start = { line = diagnostic.lnum or 0, character = diagnostic.col or 0 },
        ["end"] = {
          line = diagnostic.end_lnum or diagnostic.lnum or 0,
          character = diagnostic.end_col or diagnostic.col or 0,
        },
      },
      severity = severity,
      source = diagnostic.source or vim.NIL,
      code = diagnostic.code and tostring(diagnostic.code) or vim.NIL,
      message = diagnostic.message or "",
    }
    table.insert(diagnostics, entry)
    table.insert(summary, string.format(
      "%d. %s:%d:%d [%s]%s\n%s",
      index,
      rel or item.path,
      entry.range.start.line + 1,
      entry.range.start.character + 1,
      severity,
      diagnostic.source and (" (" .. diagnostic.source .. ")") or "",
      entry.message
    ))
  end

  if #summary > 0 then
    table.insert(summary, 1, "")
    table.insert(summary, 1, string.format(
      "Returned %d diagnostics (limit %d, total after filtering %d, truncated: %s).",
      math.min(#filtered, limit),
      limit,
      #filtered,
      #filtered > limit and "yes" or "no"
    ))
  else
    summary = { string.format("Returned 0 diagnostics (limit %d, total after filtering 0, truncated: no).", limit) }
  end

  return {
    diagnostics = diagnostics,
    returnedDiagnostics = math.min(#filtered, limit),
    totalDiagnosticsAfterFiltering = #filtered,
    limit = limit,
    truncated = #filtered > limit,
    summary = summary,
  }
end

local function ensure_buffer(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 then
    bufnr = vim.fn.bufadd(path)
  end
  vim.fn.bufload(bufnr)
  return bufnr
end

local function location_to_entry(location)
  local uri = location.uri or location.targetUri
  if not uri then
    return nil
  end
  local range = location.range or location.targetSelectionRange or location.targetRange
  if not range then
    return nil
  end
  local path = util.normalize(vim.uri_to_fname(uri))
  return {
    filePath = path,
    relativePath = relative_path(path) or vim.NIL,
    range = {
      start = {
        line = range.start.line or 0,
        character = range.start.character or 0,
      },
      ["end"] = {
        line = range["end"].line or 0,
        character = range["end"].character or 0,
      },
    },
  }
end

local function references(args)
  args = args or {}
  local path = resolve_file(args.file)
  if not path then
    error("Unable to locate file " .. tostring(args.file) .. " in the current workspace.")
  end

  local bufnr = ensure_buffer(path)
  local params = {
    textDocument = { uri = vim.uri_from_fname(path) },
    position = args.position or { line = 0, character = 0 },
    context = { includeDeclaration = args.includeDeclaration ~= false },
  }
  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/references", params, config.get().mcp.tool_timeout_ms)
  local items = {}
  for _, response in pairs(responses or {}) do
    for _, location in ipairs(response.result or {}) do
      local entry = location_to_entry(location)
      if entry then
        table.insert(items, entry)
      end
    end
  end

  if args.includeDeclaration == false then
    local line = params.position.line
    local character = params.position.character
    items = vim.tbl_filter(function(item)
      return not (item.filePath == path and item.range.start.line == line and item.range.start.character == character)
    end, items)
  end

  local summary = {}
  for index, item in ipairs(items) do
    table.insert(summary, string.format(
      "%d. %s:%d:%d",
      index,
      item.relativePath ~= vim.NIL and item.relativePath or item.filePath,
      item.range.start.line + 1,
      item.range.start.character + 1
    ))
  end
  if #summary > 0 then
    table.insert(summary, 1, "")
    table.insert(summary, 1, string.format("Returned %d references.", #items))
  else
    summary = { "Returned 0 references." }
  end

  return {
    references = items,
    returnedReferences = #items,
    summary = summary,
  }
end

local function workspace_symbols(args)
  args = args or {}
  local query = args.query or ""
  local limit = math.min(tonumber(args.maxSymbols) or 100, 500)
  local bufnr = vim.api.nvim_get_current_buf()
  local responses = vim.lsp.buf_request_sync(bufnr, "workspace/symbol", { query = query }, config.get().mcp.tool_timeout_ms)
  local symbols = {}

  for _, response in pairs(responses or {}) do
    for _, symbol in ipairs(response.result or {}) do
      if #symbols >= limit then
        break
      end
      local location = symbol.location or {}
      local entry = location_to_entry(location)
      if entry then
        table.insert(symbols, {
          name = symbol.name or "",
          kind = symbol_kinds[symbol.kind] or "unknown",
          containerName = symbol.containerName or vim.NIL,
          location = entry,
        })
      end
    end
  end

  local summary = {}
  for index, symbol in ipairs(symbols) do
    local loc = symbol.location
    local rel = loc.relativePath ~= vim.NIL and loc.relativePath or loc.filePath
    local display = symbol.containerName ~= vim.NIL and (symbol.containerName .. "." .. symbol.name) or symbol.name
    table.insert(summary, string.format(
      "%d. %s (%s) - %s:%d:%d",
      index,
      display,
      symbol.kind,
      rel,
      loc.range.start.line + 1,
      loc.range.start.character + 1
    ))
  end

  local truncated = #symbols >= limit
  if #summary > 0 then
    table.insert(summary, 1, "")
    table.insert(summary, 1, string.format(
      "Returned %d symbols (limit %d, total %d, truncated: %s).",
      #symbols,
      limit,
      #symbols,
      truncated and "yes" or "no"
    ))
  else
    summary = { string.format("Returned 0 symbols (limit %d, total 0, truncated: no).", limit) }
  end

  return {
    symbols = symbols,
    returnedSymbols = #symbols,
    totalSymbols = #symbols,
    limit = limit,
    truncated = truncated,
    summary = summary,
  }
end

local tools = {
  vscodeDiagnostics = {
    title = "VS Code Diagnostics",
    description = "Retrieve diagnostics from Neovim's diagnostic store with optional filters.",
    inputSchema = {
      type = "object",
      properties = {
        maxDiagnostics = { type = "integer", default = 50, minimum = 1, maximum = 1000 },
        file = { type = "string" },
        source = { anyOf = { { type = "string" }, { type = "array", items = { type = "string" } } } },
        code = { anyOf = { { type = "string" }, { type = "array", items = { type = "string" } } } },
        includeNonWorkspaceDiagnostics = { type = "boolean", default = false },
        minSeverity = { type = "string", enum = { "error", "warning", "information", "hint" }, default = "information" },
      },
    },
    call = list_diagnostics,
  },
  vscodeReferences = {
    title = "VS Code References",
    description = "Retrieve references for a symbol using Neovim LSP.",
    inputSchema = {
      type = "object",
      required = { "file", "position" },
      properties = {
        file = { type = "string" },
        position = {
          type = "object",
          required = { "line", "character" },
          properties = {
            line = { type = "integer", minimum = 0 },
            character = { type = "integer", minimum = 0 },
          },
        },
        includeDeclaration = { type = "boolean", default = true },
      },
    },
    call = references,
  },
  vscodeWorkspaceSymbols = {
    title = "VS Code Workspace Symbols",
    description = "Search workspace symbols via Neovim LSP.",
    inputSchema = {
      type = "object",
      required = { "query" },
      properties = {
        query = { type = "string", minLength = 1 },
        maxSymbols = { type = "integer", default = 100, minimum = 1, maximum = 500 },
      },
    },
    call = workspace_symbols,
  },
}

local function tool_list()
  local result = {}
  for name, tool in pairs(tools) do
    table.insert(result, {
      name = name,
      title = tool.title,
      description = tool.description,
      inputSchema = tool.inputSchema,
    })
  end
  table.sort(result, function(a, b)
    return a.name < b.name
  end)
  return result
end

local function handle_request(message)
  local id = message.id
  if message.method == "initialize" then
    return {
      jsonrpc = "2.0",
      id = id,
      result = {
        protocolVersion = (message.params and message.params.protocolVersion) or "2025-06-18",
        capabilities = { tools = { listChanged = false } },
        serverInfo = { name = "nvim-codex-lsp-mcp-server", version = "0.1.0" },
      },
    }
  end

  if message.method == "tools/list" then
    return {
      jsonrpc = "2.0",
      id = id,
      result = { tools = tool_list() },
    }
  end

  if message.method == "tools/call" then
    local name = message.params and message.params.name
    local tool = tools[name]
    if not tool then
      return error_response(id, -32602, "Unknown tool: " .. tostring(name))
    end
    local ok, result = pcall(tool.call, (message.params and message.params.arguments) or {})
    if not ok then
      return error_response(id, -32000, tostring(result))
    end
    return text_response(id, result)
  end

  if message.method == "ping" then
    return { jsonrpc = "2.0", id = id, result = {} }
  end

  return error_response(id, -32601, "Method not found: " .. tostring(message.method))
end

local function attach_client(pipe)
  local client = { pipe = pipe, buffer = "" }
  table.insert(state.clients, client)
  pipe:read_start(function(err, chunk)
    if err or not chunk then
      if not pipe:is_closing() then
        pipe:close()
      end
      return
    end
    client.buffer = client.buffer .. chunk
    while true do
      local newline = client.buffer:find("\n", 1, true)
      if not newline then
        break
      end
      local line = client.buffer:sub(1, newline - 1)
      client.buffer = client.buffer:sub(newline + 1)
      if line:match("%S") then
        local ok, message = pcall(util.json_decode, line)
        if ok and message.id ~= nil then
          vim.schedule(function()
            local response = handle_request(message)
            if not pipe:is_closing() then
              pipe:write(util.json_encode(response) .. "\n")
            end
          end)
        end
      end
    end
  end)
end

function M.start()
  if state.server then
    return state.socket_path
  end

  local opts = config.get()
  local mcp_opts = opts.mcp or {}
  local pid = util.uv.os_getpid and util.uv.os_getpid() or vim.fn.getpid()
  local socket_dir = mcp_opts.socket_dir
    or util.joinpath(util.tmpdir(), "nvim-codex-lsp-mcp-" .. tostring(util.uid() or pid) .. "-" .. tostring(pid))
  vim.fn.mkdir(socket_dir, "p")

  local socket_path = mcp_opts.socket_path or util.joinpath(socket_dir, "lsp-mcp.sock")
  pcall(util.uv.fs_unlink, socket_path)

  local server = util.uv.new_pipe(false)
  local ok, bind_result, bind_err = pcall(function()
    return server:bind(socket_path)
  end)
  if not ok or bind_err or (bind_result ~= nil and bind_result ~= 0) then
    error(tostring(bind_err or (ok and bind_result) or "failed to bind MCP socket"))
  end

  server:listen(32, function(err)
    if err then
      util.notify("Codex MCP listen error: " .. tostring(err), vim.log.levels.WARN)
      return
    end
    local pipe = util.uv.new_pipe(false)
    server:accept(pipe)
    attach_client(pipe)
  end)

  state.server = server
  state.socket_dir = socket_dir
  state.socket_path = socket_path
  return socket_path
end

function M.stop()
  for _, client in ipairs(state.clients) do
    if client.pipe and not client.pipe:is_closing() then
      client.pipe:read_stop()
      client.pipe:close()
    end
  end
  state.clients = {}

  if state.server and not state.server:is_closing() then
    state.server:close()
  end
  state.server = nil
  if state.socket_path then
    pcall(util.uv.fs_unlink, state.socket_path)
  end
  state.socket_path = nil
end

function M.get_socket_path()
  return state.socket_path
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function toml_string(value)
  return util.json_encode(value)
end

local function toml_array(values)
  local encoded = {}
  for _, value in ipairs(values) do
    table.insert(encoded, toml_string(value))
  end
  return "[" .. table.concat(encoded, ", ") .. "]"
end

function M.codex_cli_args()
  local socket_path = M.start()
  local executable = util.find_executable(config.get().codex_executable or "codex")
  local server_config = string.format(
    "mcp_servers.codex-lsp-mcp={command = %s, args = %s}",
    toml_string(executable),
    toml_array({ "stdio-to-uds", socket_path })
  )
  return table.concat({
    shell_quote(executable),
    "--config",
    shell_quote(server_config),
  }, " ")
end

function M._tools()
  return tools
end

return M
