-- Choose one TypeScript server for each project based on its root package.json.
-- https://github.com/microsoft/typescript-go
local function project_root(bufnr)
    local root_markers = {
        { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" },
        { ".git" },
    }

    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
    local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
    local root = vim.fs.root(bufnr, root_markers)

    -- Leave files in Deno projects available for denols instead.
    if deno_lock_root and (not root or #deno_lock_root > #root) then
        return nil
    end

    if deno_root and (not root or #deno_root >= #root) then
        return nil
    end

    return root or vim.fn.getcwd()
end

local function uses_native_preview(root)
    local package_path = vim.fs.joinpath(root, "package.json")
    if vim.fn.filereadable(package_path) ~= 1 then
        return false
    end

    local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_path), "\n"))
    if not ok or type(package) ~= "table" then
        return false
    end

    for _, dependency_group in ipairs({
        "dependencies",
        "devDependencies",
        "optionalDependencies",
        "peerDependencies",
    }) do
        local dependencies = package[dependency_group]
        if type(dependencies) == "table" and dependencies["@typescript/native-preview"] then
            return true
        end
    end

    return false
end

local function root_dir_for_native_preview(expected)
    return function(bufnr, on_dir)
        local root = project_root(bufnr)
        if root and uses_native_preview(root) == expected then
            on_dir(root)
        end
    end
end

return {
    tsgo_root_dir = root_dir_for_native_preview(true),
    vtsls_root_dir = root_dir_for_native_preview(false),
}
