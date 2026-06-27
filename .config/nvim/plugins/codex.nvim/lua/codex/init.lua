local config = require("codex.config")
local context = require("codex.context")
local ipc = require("codex.ipc")
local mcp = require("codex.mcp")
local router = require("codex.router")
local util = require("codex.util")

local M = {}

local state = {
  setup = false,
  started = false,
  router = nil,
  client = nil,
  starting = false,
  augroup = nil,
}

local function ide_handlers()
  return {
    ["ide-context"] = {
      can_handle = function(params)
        return context.can_handle(params)
      end,
      handle = function(params)
        return { ideContext = context.get_context(params) }
      end,
    },
  }
end

function M.setup(opts)
  local options = config.setup(opts)
  context.setup()

  vim.api.nvim_create_user_command("CodexIdeStart", function()
    M.start()
  end, { force = true })

  vim.api.nvim_create_user_command("CodexIdeStop", function()
    M.stop()
  end, { force = true })

  vim.api.nvim_create_user_command("CodexIdeStatus", function()
    print(vim.inspect(M.status()))
  end, { force = true })

  vim.api.nvim_create_user_command("CodexIdeCopyMcpArgs", function()
    local args = M.copy_mcp_args()
    print(args)
  end, { force = true })

  if state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
  end
  state.augroup = vim.api.nvim_create_augroup("CodexIde", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = state.augroup,
    callback = function()
      M.stop()
    end,
  })

  state.setup = true
  if options.auto_start then
    vim.schedule(function()
      M.start()
    end)
  end
end

function M.start()
  if state.started or state.starting then
    return
  end
  state.starting = true

  local socket_path = config.ipc_path()
  router.ensure(socket_path, function(err, created_router)
    if err then
      state.starting = false
      util.notify("Failed to start Codex IPC router: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    state.router = created_router
    vim.defer_fn(function()
      state.client = ipc.Client.new({
        socket_path = socket_path,
        client_type = config.get().client_type,
        handlers = ide_handlers(),
        request_timeout_ms = config.get().request_timeout_ms,
      })

      state.client:connect(function(connect_err)
        state.starting = false
        if connect_err then
          util.notify("Failed to connect Codex IDE client: " .. tostring(connect_err), vim.log.levels.ERROR)
          return
        end

        state.started = true
        if config.get().mcp and config.get().mcp.enabled then
          pcall(mcp.start)
        end
      end)
    end, created_router and 50 or 0)
  end)
end

function M.stop()
  if state.client then
    state.client:close()
    state.client = nil
  end
  if state.router then
    state.router:close()
    state.router = nil
  end
  mcp.stop()
  state.started = false
  state.starting = false
end

function M.status()
  return {
    setup = state.setup,
    started = state.started,
    starting = state.starting,
    ownsRouter = state.router ~= nil,
    ipcSocket = config.ipc_path(),
    clientId = state.client and state.client.client_id or vim.NIL,
    mcpSocket = mcp.get_socket_path() or vim.NIL,
  }
end

function M.copy_mcp_args()
  local args = mcp.codex_cli_args()
  pcall(vim.fn.setreg, "+", args)
  return args
end

function M.get_context(params)
  return context.get_context(params)
end

return M
