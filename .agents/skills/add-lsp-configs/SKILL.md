---
name: add-lsp-configs
description: Add or update Neovim 0.12 language-server configurations using native vim.lsp APIs, nvim-lspconfig defaults, vim.pack, and Mise-managed server executables. Use when adding a language server, migrating an LSP spec, changing server settings, enabling LSP formatting, or validating LSP behavior in the dotfiles2 Neovim configuration.
---

# Add Neovim LSP Configs

Use Neovim's native LSP configuration model and keep each server override minimal.

## Inspect the current setup

1. Read `dot_config/nvim/init.lua`, `dot_config/nvim/lua/config/plugins.lua`, existing `dot_config/nvim/after/lsp/` files, and any central LSP-enabling module before editing.
2. Confirm Neovim 0.12 or newer is targeted and `neovim/nvim-lspconfig` is already registered through `vim.pack`.
3. Consult both official sources before choosing names or settings:
   - https://github.com/neovim/nvim-lspconfig/tree/master
   - https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
4. Verify the exact config name, executable, filetypes, root markers, and defaults. Do not infer them from memory.

## Add one server

Prefer `dot_config/nvim/after/lsp/<server>.lua` for overrides. Return only values that differ from nvim-lspconfig's defaults:

```lua
return {
    settings = {
        Example = {},
    },
}
```

Enable the config with Neovim's native API:

```lua
vim.lsp.enable("server_name")
```

Keep enabled server names in the repository's central LSP module. If none exists, create `dot_config/nvim/lua/config/lsp.lua` and require it from `init.lua` after `config.plugins`.

Use `vim.lsp.config("server_name", overrides)` only when a returned `after/lsp` config is unsuitable. Never use deprecated `require("lspconfig").server.setup()` calls.

## Keep dependencies minimal

- Do not add Lazy.nvim, Mason, or another LSP manager.
- Do not register `nvim-lspconfig` again when it already exists in `config.plugins`.
- Check whether the server executable is reproducibly installed. If absent, add the appropriate tool to `mise.toml`; verify its Mise backend and tool name instead of guessing.
- Prefer a server's built-in formatter when it supports one. Do not add an external formatter unless the user requests it.
- Preserve project-local server configuration files such as `.luarc.json`, `pyproject.toml`, or `tsconfig.json`; avoid overriding their settings globally.

## Validate the result

1. Compile every changed Lua file with Neovim 0.12 or newer.
2. Confirm the server executable resolves on `PATH`.
3. Start Neovim with a representative file and confirm the intended config is enabled with `vim.lsp.is_enabled("server_name")`.
4. When a project root and executable are available, confirm attachment with `vim.lsp.get_clients({ bufnr = 0 })` and run `:checkhealth vim.lsp` if troubleshooting is needed.
5. Run `git diff --check` and review the diff for unrelated plugin, formatting, keymap, or diagnostic changes.
