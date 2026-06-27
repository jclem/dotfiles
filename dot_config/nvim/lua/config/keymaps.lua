local function copy_path_with_lines(path)
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    local suffix
    if start_line == end_line then
        suffix = "#L" .. start_line
    else
        suffix = "#L" .. start_line .. "-L" .. end_line
    end

    vim.fn.setreg("+", path .. suffix)
end

require("which-key").add({
    -- Splits
    { "<leader>-",  "<cmd>split<cr>",  desc = "Split (below)" },
    { "<leader>\\", "<cmd>vsplit<cr>", desc = "Split (right)" },

    -- Buffers
    { "<leader>b",  group = "Buffers" },
    {
        "<leader>bc",
        function()
            vim.fn.setreg("+", vim.fn.expand("%:."))
        end,
        desc = "Copy relative path",
    },
    {
        "<leader>bc",
        function()
            copy_path_with_lines(vim.fn.expand("%:."))
        end,
        mode = "x",
        desc = "Copy relative path with lines",
    },
    {
        "<leader>bC",
        function()
            vim.fn.setreg("+", vim.fn.expand("%:p"))
        end,
        desc = "Copy absolute path",
    },
    {
        "<leader>bC",
        function()
            copy_path_with_lines(vim.fn.expand("%:p"))
        end,
        mode = "x",
        desc = "Copy absolute path with lines",
    },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
    { "<leader>bD", "<cmd>bdelete!<cr>", desc = "Delete Buffer (no warn)" },
    { "<leader>bp", "<cmd>b#<cr>", desc = "Previous Buffer" },

    -- Files
    { "<leader>f", group = "Files" },
    { "<leader>fs", "<cmd>w<cr>", desc = "Save" },
    { "<leader>fv", "<cmd>e!<cr>", desc = "Revert", icon = { icon = "", color = "red" } },

    -- Git
    { "<leader>g", group = "Git" },

    -- Vim
    { "<leader>v", group = "Neovim", icon = "" },
    { "<leader>vq", "<cmd>qa<cr>", desc = "Quit All" },
    { "<leader>vQ", "<cmd>qa!<cr>", desc = "Quit All (no warn)" },

    -- Marks
    { "<leader>m", group = "Marks" },
    { "<leader>mx", "<cmd>delm! | delm A-Z0-9<cr>", desc = "Delete Marks" },

    -- Diagnostics
    { "<leader>d", group = "Diagnostics" },
    { "<leader>dd", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Open Diagnostics" },
    { "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Set Location List" },
    { "<leader>dq", "<cmd>lua vim.diagnostic.setqflist()<cr>", desc = "Set Quickfix List" },

    -- Help
    {
        "<leader>?",
        function()
            require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
    },

})

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

-- Toggle LSP completion explicitly. Use Control-N/Control-P to select and
-- Control-Y to accept a candidate.
vim.keymap.set("i", "<C-Space>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-e>"
    end

    vim.lsp.completion.get()
    return ""
end, { desc = "Toggle LSP completion", expr = true })

-- Navigate splits with the same directional keys used elsewhere in Neovim.
-- Zellij must be locked for it to pass these key combinations through.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })

-- Use mouse side buttons to move through the jump list.
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump back", silent = true })
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward", silent = true })

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
