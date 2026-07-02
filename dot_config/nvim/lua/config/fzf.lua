-- Configure FzfLua for file discovery.
-- https://github.com/ibhagwan/fzf-lua
local fzf = require("fzf-lua")

fzf.setup({
    "ivy",
    marks = { marks = "[A-Za-z]" },
})

vim.keymap.set("n", "<leader>bl", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>db", fzf.diagnostics_document, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>dw", fzf.diagnostics_workspace, { desc = "Workspace Diagnostics" })
vim.keymap.set("n", "<leader>fd", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>gC", fzf.git_commits, { desc = "Commits" })
vim.keymap.set("n", "<leader>gc", fzf.git_bcommits, { desc = "Commits (buffer)" })
vim.keymap.set("n", "<leader>ml", fzf.marks, { desc = "Marks" })
vim.keymap.set("n", "<leader>vc", fzf.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader>vh", fzf.helptags, { desc = "Help" })
