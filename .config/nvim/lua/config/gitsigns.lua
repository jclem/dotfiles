-- Show Git changes in the sign column and expose buffer-local Git actions.
-- https://github.com/lewis6991/gitsigns.nvim
local gitsigns = require("gitsigns")

gitsigns.setup({
    signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
    },
    signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
    },
})

vim.keymap.set("n", "<leader>gs", gitsigns.toggle_signs, { desc = "Toggle Git signs" })
vim.keymap.set("n", "<leader>gl", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
