return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				lua_ls = {
					settings = {
						-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
						on_init = function(client)
							if client.workspace_folders then
								local path = client.workspace_folders[1].name
								if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
									return
								end
							end

							client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
								runtime = { version = 'LuaJIT' },
								workspace = {
									checkThirdParty = false,
									library = {
										vim.env.VIMRUNTIME,
										"${3rd}/luv/library",
									}
								}
							})
						end,
					},
				},
			},
		},
	},
}
