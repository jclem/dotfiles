-- Configure mini.files as the file explorer.
-- https://github.com/nvim-mini/mini.files
local files = require("mini.files")

files.setup()

vim.keymap.set("n", "\\", function()
    if not files.close() then
        files.open()
    end
end, { desc = "Toggle file tree" })
