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
