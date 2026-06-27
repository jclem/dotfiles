local util = require("codex.util")

local M = {}

M.defaults = {
  auto_start = true,
  client_type = "neovim",
  codex_executable = "codex",
  workspace_roots = nil,
  selection_max_bytes = 200000,
  recent_tab_limit = 5,
  request_timeout_ms = 10000,
  mcp = {
    enabled = true,
    socket_dir = nil,
    socket_path = nil,
    tool_timeout_ms = 5000,
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = util.tbl_deep_extend(vim.deepcopy(M.defaults), opts or {})
  if vim.g.codex_ide_auto_start ~= nil then
    M.options.auto_start = vim.g.codex_ide_auto_start == 1 or vim.g.codex_ide_auto_start == true
  end
  return M.options
end

function M.get()
  return M.options
end

function M.ipc_path()
  if util.is_windows() then
    return "\\\\.\\pipe\\codex-ipc"
  end

  local dir = util.joinpath(util.tmpdir(), "codex-ipc")
  vim.fn.mkdir(dir, "p")
  local uid = util.uid()
  local name = uid and uid ~= 0 and ("ipc-" .. tostring(uid) .. ".sock") or "ipc.sock"
  return util.joinpath(dir, name)
end

function M.workspace_roots()
  local roots = {}
  local opts = M.get()

  local function add(path)
    if path and path ~= "" then
      local normalized = util.normalize(path)
      if not vim.tbl_contains(roots, normalized) then
        table.insert(roots, normalized)
      end
    end
  end

  if opts.workspace_roots then
    for _, root in ipairs(opts.workspace_roots) do
      add(root)
    end
  end

  for _, folder in ipairs(vim.lsp.buf.list_workspace_folders()) do
    add(folder)
  end

  add(vim.fn.getcwd())
  return roots
end

return M
