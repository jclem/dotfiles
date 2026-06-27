-- Fall back to vtsls for projects that have not opted into tsgo.
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/vtsls.lua
return {
    root_dir = require("config.typescript").vtsls_root_dir,
}
