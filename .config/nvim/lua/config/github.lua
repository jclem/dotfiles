-- Build permanent GitHub links from the current buffer without requiring an
-- authenticated GitHub CLI session.
-- https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files
local function git(cwd, args)
    local command = { "git", "-C", cwd }
    vim.list_extend(command, args)

    local result = vim.system(command, { text = true }):wait()
    local stdout = vim.trim(result.stdout or "")

    if result.code ~= 0 then
        local stderr = vim.trim(result.stderr or "")
        return nil, stderr ~= "" and stderr or stdout
    end

    return stdout
end

local function git_remote(root)
    local remote = git(root, { "remote", "get-url", "origin" })
    if remote then
        return remote
    end

    local output, err = git(root, { "remote" })
    if not output then
        return nil, err
    end

    local remotes = vim.split(output, "\n", { plain = true, trimempty = true })
    if not remotes[1] then
        return nil, "No Git remotes found"
    end

    return git(root, { "remote", "get-url", remotes[1] })
end

local function github_base(remote)
    local host, path = remote:match("^[^@]+@([^:]+):(.+)$")
    if not host then
        host, path = remote:match("^ssh://[^@/]+@([^/]+)/(.+)$")
    end
    if not host then
        host, path = remote:match("^ssh://([^/]+)/(.+)$")
    end
    if not host then
        host, path = remote:match("^https?://[^@/]+@([^/]+)/(.+)$")
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

    path = path:gsub("/$", ""):gsub("%.git$", "")
    return ("https://%s/%s"):format(host, path)
end

local function encode_path(path)
    local segments = vim.split(path, "/", { plain = true })

    for index, segment in ipairs(segments) do
        segments[index] = vim.uri_encode(segment, "rfc3986")
    end

    return table.concat(segments, "/")
end

local function line_fragment(include_lines)
    if not include_lines then
        return ""
    end

    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    if start_line == end_line then
        return ("#L%d"):format(start_line)
    end

    return ("#L%d-L%d"):format(start_line, end_line)
end

local function permalink(opts)
    opts = opts or {}

    local buffer_path = vim.api.nvim_buf_get_name(0)
    if buffer_path == "" then
        return nil, "The current buffer has no file"
    end

    buffer_path = vim.uv.fs_realpath(buffer_path) or vim.fs.normalize(buffer_path)
    local directory = vim.fs.dirname(buffer_path)
    local root, root_err = git(directory, { "rev-parse", "--show-toplevel" })
    if not root then
        return nil, root_err ~= "" and root_err or "The current file is not in a Git repository"
    end

    root = vim.uv.fs_realpath(root) or vim.fs.normalize(root)

    local relative_path = vim.fs.relpath(root, buffer_path)
    if not relative_path then
        return nil, "The current file is outside the Git repository"
    end

    local commit, commit_err = git(root, { "rev-parse", "HEAD" })
    if not commit then
        return nil, commit_err ~= "" and commit_err or "Unable to resolve HEAD"
    end

    local remote, remote_err = git_remote(root)
    if not remote then
        return nil, remote_err ~= "" and remote_err or "No Git remotes found"
    end

    local base = github_base(remote)
    if not base then
        return nil, ("Unsupported Git remote: %s"):format(remote)
    end

    local url = ("%s/blob/%s/%s%s"):format(
        base,
        commit,
        encode_path(relative_path),
        line_fragment(opts.include_lines)
    )

    return url
end

local function copy_permalink(opts)
    local url, err = permalink(opts)
    if not url then
        vim.notify(err, vim.log.levels.WARN)
        return
    end

    vim.fn.setreg("+", url)
    vim.notify("Copied GitHub permalink")
end

return {
    copy_permalink = copy_permalink,
    permalink = permalink,
}
