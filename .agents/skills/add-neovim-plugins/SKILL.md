---
name: add-neovim-plugins
description: Add, configure, update, or remove Neovim 0.12 plugins in the dotfiles repository using the native vim.pack package manager. Use when introducing a plugin, replacing a plugin, adding plugin dependencies or build hooks, configuring native plugin loading, or maintaining the Neovim package lockfile.
---

# Add Neovim Plugins

Minimize dependencies and use Neovim's native package manager.

## Inspect before adding

1. Read `dot_config/nvim/init.lua`, `dot_config/nvim/lua/config/plugins.lua`, and related configuration modules before editing.
2. Check whether Neovim 0.12 already provides the requested capability. Prefer a core feature when it is sufficient.
3. Read the plugin's current upstream documentation and release history. Verify its source URL, Neovim requirements, setup API, runtime dependencies, build steps, and version tags.
4. Read the native package documentation when loading behavior or hooks matter:
   - https://neovim.io/doc/user/pack.html#vim.pack
   - https://neovim.io/doc/user/pack.html#vim.pack.add()

## Register the plugin

Add external Git repositories to the existing `vim.pack.add()` call in `dot_config/nvim/lua/config/plugins.lua`:

```lua
vim.pack.add({
    {
        src = "https://github.com/owner/plugin",
        version = vim.version.range("*"),
    },
})
```

- Use the full HTTPS source URL.
- Follow stable semantic-version tags with `vim.version.range("*")` only when the repository publishes valid semver tags. Otherwise select a deliberate branch, tag, or revision supported by `vim.pack`.
- Add required plugin repositories as explicit specs; `vim.pack` does not interpret another manager's `dependencies` field.
- Do not copy Lazy.nvim fields such as `opts`, `config`, `keys`, `event`, or `build` into a `vim.pack` spec.
- Do not add another plugin manager.

For a repository-local plugin, add its directory to `runtimepath` instead of passing it to `vim.pack`:

```lua
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/plugins/example.nvim")
```

## Configure and load it

- Keep a very small setup call next to registration. Move substantial configuration into a focused `lua/config/<plugin>.lua` module and require it after `vim.pack.add()`.
- During `init.lua`, `vim.pack.add()` defaults to `load = false`: the package enters `runtimepath`, but its `plugin/` and `ftdetect/` scripts are not sourced. Lua modules are still available to `require()`.
- If startup scripts must run immediately, load the package explicitly with `vim.cmd.packadd("plugin-name")` or use a separate `vim.pack.add()` call with the appropriate `load` option.
- Add native autocmd, command, filetype, or keymap loading only when deferral has a clear benefit. Keep eager configuration when it is simpler.
- Use a `PackChanged` autocmd for required install/update build steps. Restrict it to the plugin name and relevant `install` or `update` events.
- Preserve the repository's four-space Lua formatting and concise comments with upstream documentation links.

## Maintain the lockfile

- Treat `dot_config/nvim/nvim-pack-lock.json` as generated configuration and commit it when `vim.pack` creates or changes it.
- Never edit lockfile revisions by hand.
- Use `:packupdate` to update packages and review its confirmation buffer before accepting changes.
- Remove obsolete specs before using `:packdel` to delete packages.

## Validate the result

1. Use Neovim 0.12 or newer and compile every changed Lua file.
2. Start Neovim with the real configuration and ensure startup completes without errors.
3. Inspect `vim.pack.get({ "plugin-name" })` to confirm the source, path, revision, and active state.
4. Exercise the plugin's smallest meaningful command, module, or behavior and run its documented health check when available.
5. Confirm required dependencies and build artifacts are present.
6. Run `git diff --check` and review the diff for unrelated plugins or configuration changes.
