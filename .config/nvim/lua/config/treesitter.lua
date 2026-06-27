-- Install parsers and enable Neovim's native Tree-sitter highlighting.
-- https://github.com/nvim-treesitter/nvim-treesitter
local parsers = {
    "bash",
    "diff",
    "eex",
    "elixir",
    "erlang",
    "heex",
    "html",
    "javascript",
    "jsdoc",
    -- The JSON parser is also registered for the jsonc filetype upstream.
    "json",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

local function install()
    return require("nvim-treesitter").install(parsers)
end

local function update()
    return require("nvim-treesitter").update(parsers)
end

local function setup()
    -- install() is a quick no-op for parsers already present and installs any
    -- additions to the list without requiring a separate bootstrap command.
    install()

    vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable Tree-sitter highlighting when a parser is available",
        callback = function(event)
            pcall(vim.treesitter.start, event.buf)
        end,
    })
end

return {
    install = install,
    setup = setup,
    update = update,
}
