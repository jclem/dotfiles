local M = {}

M.uv = vim.uv or vim.loop

local function has_vim_json()
  return vim.json and vim.json.encode and vim.json.decode
end

function M.json_encode(value)
  if has_vim_json() then
    return vim.json.encode(value)
  end
  return vim.fn.json_encode(value)
end

function M.json_decode(value)
  if has_vim_json() then
    return vim.json.decode(value)
  end
  return vim.fn.json_decode(value)
end

function M.notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = "codex.nvim" })
  end)
end

function M.tbl_deep_extend(...)
  return vim.tbl_deep_extend("force", ...)
end

function M.is_windows()
  return package.config:sub(1, 1) == "\\"
end

function M.path_sep()
  return package.config:sub(1, 1)
end

function M.tmpdir()
  local ok, value = pcall(function()
    return M.uv.os_tmpdir()
  end)
  if ok and value and value ~= "" then
    return value
  end
  return os.getenv("TMPDIR") or os.getenv("TEMP") or os.getenv("TMP") or "/tmp"
end

function M.uid()
  local ok, value = pcall(function()
    return M.uv.os_getuid()
  end)
  if ok and value ~= nil then
    return tonumber(value)
  end

  if vim.fn.executable("id") == 1 then
    local lines = vim.fn.systemlist({ "id", "-u" })
    local parsed = tonumber(lines and lines[1])
    if parsed then
      return parsed
    end
  end

  return nil
end

function M.joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end

  local sep = M.path_sep()
  local parts = { ... }
  local result = table.remove(parts, 1) or ""
  for _, part in ipairs(parts) do
    if result:sub(-1) == sep then
      result = result .. part
    else
      result = result .. sep .. part
    end
  end
  return result
end

function M.normalize(path)
  if not path or path == "" then
    return path
  end
  local ok, realpath = pcall(function()
    return M.uv.fs_realpath(path)
  end)
  if ok and realpath and realpath ~= "" then
    return realpath
  end
  if vim.fs and vim.fs.normalize then
    return vim.fs.normalize(path)
  end
  return vim.fn.fnamemodify(path, ":p")
end

function M.basename(path)
  if not path or path == "" then
    return ""
  end
  if vim.fs and vim.fs.basename then
    return vim.fs.basename(path)
  end
  return vim.fn.fnamemodify(path, ":t")
end

function M.dirname(path)
  if vim.fs and vim.fs.dirname then
    return vim.fs.dirname(path)
  end
  return vim.fn.fnamemodify(path, ":h")
end

local function canonical_for_compare(path)
  local normalized = M.normalize(path or "")
  if M.is_windows() then
    normalized = normalized:gsub("/", "\\"):lower()
  end
  return normalized:gsub("[/\\]+$", "")
end

function M.path_contains(root, path)
  if not root or root == "" or not path or path == "" then
    return false
  end

  local lhs = canonical_for_compare(root)
  local rhs = canonical_for_compare(path)
  if lhs == rhs then
    return true
  end

  local sep = M.is_windows() and "\\" or "/"
  return rhs:sub(1, #lhs + 1) == lhs .. sep
end

function M.relative_path(path, root)
  if not root or root == "" or not M.path_contains(root, path) then
    return path
  end

  local normalized_path = M.normalize(path)
  local normalized_root = M.normalize(root):gsub("[/\\]+$", "")
  local rel = normalized_path:sub(#normalized_root + 2)
  return rel == "" and M.basename(path) or rel
end

local uuid_seeded = false

function M.uuid()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  if not uuid_seeded then
    local pid = 0
    local ok, value = pcall(function()
      return M.uv.os_getpid()
    end)
    if ok and value then
      pid = tonumber(value) or 0
    end
    local seed = tonumber(tostring(M.uv.hrtime()):sub(-9)) or os.time()
    math.randomseed(seed + pid)
    uuid_seeded = true
  end
  return (template:gsub("[xy]", function(c)
    local v = c == "x" and math.random(0, 15) or math.random(8, 11)
    return string.format("%x", v)
  end))
end

function M.find_executable(name)
  if vim.fn.executable(name) == 1 then
    return vim.fn.exepath(name)
  end
  return name
end

function M.is_file_buffer(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

return M
