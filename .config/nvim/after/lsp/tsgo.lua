-- Prefer tsgo when the project opts into @typescript/native-preview.
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tsgo.lua
return {
    root_dir = require("config.typescript").tsgo_root_dir,
}
