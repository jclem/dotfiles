local config = require("codex.config")
local util = require("codex.util")

local M = {}

local augroup
local recent_tabs = {}

local function file_descriptor(path, root)
  return {
    label = util.basename(path),
    path = util.relative_path(path, root),
    fsPath = util.normalize(path),
  }
end

local function choose_root(path, requested_root)
  if requested_root and requested_root ~= "" and util.path_contains(requested_root, path) then
    return util.normalize(requested_root)
  end

  for _, root in ipairs(config.workspace_roots()) do
    if util.path_contains(root, path) then
      return root
    end
  end

  return vim.fn.getcwd()
end

local function current_window_for_buffer(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return 0
end

local function line_length(bufnr, row)
  local ok, line = pcall(vim.api.nvim_buf_get_lines, bufnr, row, row + 1, false)
  if not ok or not line or not line[1] then
    return 0
  end
  return #line[1]
end

local function pos(line, character)
  return { line = math.max(0, line), character = math.max(0, character) }
end

local function range(start_line, start_col, end_line, end_col)
  return {
    start = pos(start_line, start_col),
    ["end"] = pos(end_line, end_col),
  }
end

local function compare_positions(a_line, a_col, b_line, b_col)
  if a_line == b_line then
    return a_col - b_col
  end
  return a_line - b_line
end

local function sorted_range(a_line, a_col, b_line, b_col)
  if compare_positions(a_line, a_col, b_line, b_col) <= 0 then
    return a_line, a_col, b_line, b_col
  end
  return b_line, b_col, a_line, a_col
end

local function selection_from_cursor(bufnr, win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1] - 1
  local col = math.max(0, cursor[2])
  return range(line, col, line, col), ""
end

local function get_text(bufnr, selection_range, max_bytes)
  local start = selection_range.start
  local finish = selection_range["end"]
  if start.line == finish.line and start.character == finish.character then
    return ""
  end

  local ok, lines = pcall(
    vim.api.nvim_buf_get_text,
    bufnr,
    start.line,
    start.character,
    finish.line,
    finish.character,
    {}
  )
  if not ok then
    return ""
  end

  local text = table.concat(lines, "\n")
  if #text > max_bytes then
    return text:sub(1, max_bytes)
  end
  return text
end

local function selection_from_visual(bufnr)
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil
  end

  local cursor = vim.fn.getpos(".")
  local anchor = vim.fn.getpos("v")
  local a_line, a_col = anchor[2] - 1, math.max(0, anchor[3] - 1)
  local b_line, b_col = cursor[2] - 1, math.max(0, cursor[3] - 1)

  if mode == "V" then
    local start_line, _, end_line, _ = sorted_range(a_line, 0, b_line, 0)
    return range(start_line, 0, end_line, line_length(bufnr, end_line))
  end

  local start_line, start_col, end_line, end_col = sorted_range(a_line, a_col, b_line, b_col)
  return range(start_line, start_col, end_line, end_col + 1)
end

local function active_selection(bufnr, win)
  local max_bytes = config.get().selection_max_bytes
  local visual_range = selection_from_visual(bufnr)
  if visual_range then
    return visual_range, get_text(bufnr, visual_range, max_bytes)
  end
  return selection_from_cursor(bufnr, win)
end

local function with_selection_aliases(selection)
  return {
    start = selection.start,
    ["end"] = selection["end"],
    anchor = selection.start,
    active = selection["end"],
  }
end

local function track_path(path)
  if not path or path == "" then
    return
  end

  local normalized = util.normalize(path)
  for index, entry in ipairs(recent_tabs) do
    if entry.fsPath == normalized then
      table.remove(recent_tabs, index)
      break
    end
  end

  local root = choose_root(normalized)
  table.insert(recent_tabs, 1, file_descriptor(normalized, root))
  local limit = config.get().recent_tab_limit
  while #recent_tabs > limit do
    table.remove(recent_tabs)
  end
end

function M.track_current()
  local bufnr = vim.api.nvim_get_current_buf()
  if not util.is_file_buffer(bufnr) then
    return
  end
  track_path(vim.api.nvim_buf_get_name(bufnr))
end

function M.setup()
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
  end

  augroup = vim.api.nvim_create_augroup("CodexIdeContext", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
    group = augroup,
    callback = function()
      M.track_current()
    end,
  })

  M.track_current()
end

function M.get_context(params)
  params = params or {}
  M.track_current()

  local bufnr = vim.api.nvim_get_current_buf()
  if not util.is_file_buffer(bufnr) then
    return { activeFile = vim.NIL, openTabs = recent_tabs }
  end

  local path = util.normalize(vim.api.nvim_buf_get_name(bufnr))
  local win = current_window_for_buffer(bufnr)
  if win == 0 then
    return { activeFile = vim.NIL, openTabs = recent_tabs }
  end

  local root = choose_root(path, params.workspaceRoot)
  local selection, selected_text = active_selection(bufnr, win)
  local active = file_descriptor(path, root)
  active.selection = with_selection_aliases(selection)
  active.selections = { selection }
  active.activeSelectionContent = selected_text or ""

  return {
    activeFile = active,
    openTabs = recent_tabs,
  }
end

function M.can_handle(params)
  local root = params and params.workspaceRoot
  if not root or root == "" then
    return true
  end

  local normalized_root = util.normalize(root)
  for _, workspace_root in ipairs(config.workspace_roots()) do
    if util.path_contains(workspace_root, normalized_root) or util.path_contains(normalized_root, workspace_root) then
      return true
    end
  end

  for _, tab in ipairs(recent_tabs) do
    if util.path_contains(normalized_root, tab.fsPath) then
      return true
    end
  end

  local active = vim.api.nvim_buf_get_name(0)
  return active ~= "" and util.path_contains(normalized_root, active)
end

function M._reset_for_tests()
  recent_tabs = {}
end

return M
