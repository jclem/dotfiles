local M = {}

local function git_cmd(cwd, args)
  local cmd = { "git", "-C", cwd }
  vim.list_extend(cmd, args)

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(output, "\n")
  end

  return output[1], nil
end

local function git_root(cwd)
  return git_cmd(cwd, { "rev-parse", "--show-toplevel" })
end

local function git_commitish(root)
  local commit = git_cmd(root, { "rev-parse", "HEAD" })
  if commit then
    return commit
  end

  return git_cmd(root, { "symbolic-ref", "--short", "HEAD" })
end

local function git_remote(root)
  local remote = git_cmd(root, { "remote", "get-url", "origin" })
  if remote then
    return remote
  end

  local remotes = vim.fn.systemlist({ "git", "-C", root, "remote" })
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(remotes, "\n")
  end

  if not remotes[1] or remotes[1] == "" then
    return nil, "No git remotes found"
  end

  return git_cmd(root, { "remote", "get-url", remotes[1] })
end

local function normalize_remote(remote)
  local host, path = remote:match("^git@([^:]+):(.+)$")
  if not host then
    host, path = remote:match("^ssh://[^@]+@([^/]+)/(.+)$")
  end
  if not host then
    host, path = remote:match("^ssh://([^/]+)/(.+)$")
  end
  if not host then
    host, path = remote:match("^https?://([^/]+)/(.+)$")
  end
  if not host then
    host, path = remote:match("^git://([^/]+)/(.+)$")
  end
  if not host then
    return nil
  end

  path = path:gsub("/$", "")
  path = path:gsub("%.git$", "")

  return ("https://%s/%s"):format(host, path)
end

local function relative_path(root, buf_abs)
  if not vim.startswith(buf_abs, root .. "/") then
    return nil
  end

  return buf_abs:sub(#root + 2)
end

local function line_suffix(opts)
  if not opts.include_lines then
    return ""
  end

  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  if start_line == end_line then
    return ("#L%s"):format(start_line)
  end

  return ("#L%s-L%s"):format(start_line, end_line)
end

function M.copy_github_link(opts)
  opts = opts or {}

  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local buf_abs = vim.fn.fnamemodify(bufname, ":p")
  local dir = vim.fn.fnamemodify(buf_abs, ":p:h")

  local root = git_root(dir)
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local commitish, commit_err = git_commitish(root)
  if not commitish then
    local message = commit_err or "Unable to resolve git commit-ish"
    vim.notify(message, vim.log.levels.ERROR)
    return
  end

  local remote, remote_err = git_remote(root)
  if not remote then
    local message = remote_err or "No git remotes found"
    vim.notify(message, vim.log.levels.WARN)
    return
  end

  local base = normalize_remote(remote)
  if not base then
    vim.notify(("Unsupported git remote: %s"):format(remote), vim.log.levels.ERROR)
    return
  end

  local rel = relative_path(root, buf_abs)
  if not rel then
    vim.notify("Buffer is outside git root", vim.log.levels.WARN)
    return
  end

  local url = ("%s/blob/%s/%s%s"):format(base, commitish, rel, line_suffix(opts))
  vim.fn.setreg("+", url)
  vim.notify("Copied GitHub link to clipboard")
end

return M
