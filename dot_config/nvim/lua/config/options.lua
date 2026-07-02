-- Configure Neovim's built-in editing behavior.
-- https://neovim.io/doc/user/options.html

-- Opt into Neovim 0.12's experimental replacement for the command-line and
-- message UI. Guard it because reloading this configuration must not attach it
-- to the same UI twice.
-- https://neovim.io/doc/user/lua.html#ui2
if not vim.g.ui2_enabled then
    require("vim._core.ui2").enable({
        msg = {
            targets = "msg",
        },
    })
    vim.g.ui2_enabled = true
end

-- mini.files is the configured file explorer, so do not load netrw's explorer.
-- https://neovim.io/doc/user/pi_netrw.html#netrw-noload
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Neovim already recognizes the Elixir and EEx extensions from the old config.
-- This custom extension is used for standalone Zellij layout files.
-- https://neovim.io/doc/user/lua.html#vim.filetype.add()
vim.filetype.add({
    extension = {
        zellij = "kdl",
    },
})

-- Use the EEx parser for the `eelixir` filetype when that parser is available.
-- https://neovim.io/doc/user/treesitter.html#vim.treesitter.language.register()
vim.treesitter.language.register("eex", "eelixir")

-- Save modified buffers before commands that move between files or run builds.
vim.o.autowrite = true

-- Make the current location and structural UI consistently visible.
vim.o.cursorline = true
vim.o.number = true
vim.o.scrolloff = 10
vim.o.showmatch = true
vim.o.signcolumn = "yes"

-- Preview substitutions in a split without changing the current buffer first.
vim.o.inccommand = "split"

-- Enable mouse input in every mode, including command-line and terminal modes.
vim.o.mouse = "a"

-- Put new windows where reading order naturally continues.
vim.o.splitbelow = true
vim.o.splitright = true

-- Use rounded borders for floating windows unless a plugin overrides them.
vim.o.winborder = "rounded"

-- Use full terminal colors for the Folio colorscheme.
vim.o.termguicolors = true

-- Keep multi-key mappings responsive and reduce idle-event latency.
vim.o.timeoutlen = 300
vim.o.updatetime = 250

-- Search case-insensitively unless the query contains an uppercase character.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Do not create recovery swapfiles for open buffers.
-- https://neovim.io/doc/user/options.html#'swapfile'
vim.o.swapfile = false

-- Preserve undo history between editing sessions. Neovim 0.12 already places
-- these files under stdpath("state"), so no custom undo directory is needed.
vim.o.undofile = true

-- Use two-space indentation by default while displaying literal tabs at four
-- columns. Filetype plugins can override these defaults where conventions differ.
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 4

-- Prefix wrapped continuation lines so they remain visually distinguishable.
vim.o.showbreak = "┕━ "

-- Keep useful whitespace glyphs ready for `:set list` without showing them by
-- default. Tabs, trailing spaces, and non-breaking spaces each get a distinct mark.
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Let Tree-sitter calculate folds, but start with every fold open. Languages
-- without an installed parser simply have no syntax-derived folds.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99
