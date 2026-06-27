vim.keymap.set("n", "<leader>bc", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>bC", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- Clear search highlighting while preserving the current search pattern.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlighting" })

-- Enter command-line mode without reaching for Shift. This intentionally
-- replaces `;`, whose default behavior repeats the latest f/F/t/T motion.
vim.keymap.set({ "n", "x" }, ";", ":", { desc = "Enter command mode" })

-- Copy an explicit visual selection to the system clipboard. Ordinary yanks
-- continue to use Neovim's registers without changing the macOS clipboard.
vim.keymap.set("x", "<leader>c", '"+y', { desc = "Copy selection" })

-- Copy a stable link to the current file, including selected lines in Visual mode.
local github = require("config.github")
vim.keymap.set("n", "<leader>gh", github.copy_permalink, { desc = "Copy GitHub permalink" })
vim.keymap.set("x", "<leader>gh", function()
    github.copy_permalink({ include_lines = true })
end, { desc = "Copy GitHub permalink with lines" })

-- Treat Control-C like Escape in Insert mode so InsertLeave autocmds run.
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Request LSP completion explicitly when an automatic result needs refreshing.
-- Use Control-N/Control-P to select and Control-Y to accept a candidate.
vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { desc = "Show LSP completion" })

-- Navigate splits with the same directional keys used elsewhere in Neovim.
-- Zellij must be locked for it to pass these key combinations through.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })

-- Use mouse side buttons to move through the jump list.
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump back", silent = true })
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward", silent = true })

vim.keymap.set("n", "<leader>vq", "<cmd>quit<cr>", { desc = "Quit Neovim" })

-- Reload repository-owned configuration modules without closing the session.
vim.keymap.set("n", "<leader>vr", function()
    for name in pairs(package.loaded) do
        if name:match("^config%.") then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify("Reloaded Neovim configuration")
end, { desc = "Reload Neovim configuration" })
