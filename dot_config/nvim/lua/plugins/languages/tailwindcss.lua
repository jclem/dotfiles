return {
	"neovim/nvim-lspconfig",
	opts = function()
		local function is_readable(path)
			return vim.fn.filereadable(path) == 1
		end

		local function file_contains_tailwind_import(path)
			if not is_readable(path) then
				return false
			end

			local ok, lines = pcall(vim.fn.readfile, path, "", 80)
			if not ok then
				return false
			end

			local content = table.concat(lines, "\n")
			return content:find("@import%s+[\"']tailwindcss[\"']") ~= nil
		end

		local function find_tailwind_entrypoint(root_dir)
			if not root_dir or root_dir == "" then
				return nil
			end

			local candidates = {
				"src/app/globals.css",
				"app/globals.css",
				"src/styles/app.css",
				"src/styles/globals.css",
				"styles/globals.css",
				"src/index.css",
				"index.css",
				"globals.css",
			}

			for _, relative_path in ipairs(candidates) do
				local absolute_path = root_dir .. "/" .. relative_path
				if file_contains_tailwind_import(absolute_path) then
					return relative_path
				end
			end

			return nil
		end

		local default_config = vim.lsp.config.tailwindcss or {}
		local default_before_init = default_config.before_init
		local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/tailwindcss-language-server"
		local has_mason_bin = vim.fn.executable(mason_bin) == 1
		local has_global_bin = vim.fn.executable("tailwindcss-language-server") == 1

		vim.lsp.config("tailwindcss", {
			cmd = has_mason_bin and { mason_bin, "--stdio" } or { "tailwindcss-language-server", "--stdio" },
			before_init = function(init_params, config)
				if default_before_init then
					default_before_init(init_params, config)
				end

				local entrypoint = find_tailwind_entrypoint(config.root_dir)
				if not entrypoint then
					return
				end

				config.settings = config.settings or {}
				config.settings.tailwindCSS = vim.tbl_deep_extend("force", config.settings.tailwindCSS or {}, {
					experimental = {
						configFile = entrypoint,
					},
				})
			end,
		})

		if has_mason_bin or has_global_bin then
			vim.lsp.enable("tailwindcss")
		end
	end,
}
