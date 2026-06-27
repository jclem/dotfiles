-- Configure mini.files as the file explorer.
-- https://github.com/nvim-mini/mini.files
local files = require("mini.files")

files.setup()

local function toggle()
    if not files.close() then
        files.open()
    end
end

vim.keymap.set("n", "\\", toggle, { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>ft", toggle, { desc = "Toggle file tree" })

vim.keymap.set("n", "<leader>fT", function()
    files.open(vim.api.nvim_buf_get_name(0))
end, { desc = "Reveal current file in file tree" })
