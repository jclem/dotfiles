-- Configure FzfLua for file discovery.
-- https://github.com/ibhagwan/fzf-lua
local fzf = require("fzf-lua")

fzf.setup()

vim.keymap.set("n", "<leader>fd", fzf.files, { desc = "Find files" })
