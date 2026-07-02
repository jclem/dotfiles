-- Use Copilot as a Blink completion source without competing suggestion UIs.
-- https://github.com/zbirenbaum/copilot.lua
require("copilot").setup({
    panel = { enabled = false },
    suggestion = { enabled = false },
})
