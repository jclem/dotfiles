return {
	"neovim/nvim-lspconfig",
	opts = function()
		local util = require("lspconfig.util")

		local function buffer_root_dir(bufnr)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			if fname == "" then
				return vim.uv.cwd() or vim.fn.getcwd()
			end

			return util.root_pattern(".git")(fname) or vim.uv.cwd() or vim.fn.getcwd()
		end

		local function file_exists(path)
			return vim.fn.filereadable(vim.fn.expand(path)) == 1
		end

		local function executable(path)
			return vim.fn.executable(vim.fn.expand(path)) == 1
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local ok, blink = pcall(require, "blink.cmp")
		if ok then
			capabilities = blink.get_lsp_capabilities(capabilities)
		end

		local root_dir = buffer_root_dir(vim.api.nvim_get_current_buf())

		-- Prefer the project-local biome binary over the global one.
		local biome_cmd = { "biome", "lsp-proxy" }
		local local_biome = root_dir .. "/node_modules/.bin/biome"
		if file_exists(local_biome) then
			biome_cmd = { local_biome, "lsp-proxy" }
		end

		vim.lsp.config("biome", { cmd = biome_cmd, capabilities = capabilities })
		vim.lsp.enable("biome")
		vim.lsp.enable("eslint")

		local useTSGo = file_exists(root_dir .. "/node_modules/@typescript/native-preview/package.json")

		-- If TSGO=0 or TSGO=false is set in the environment, do not use tsgo.
		local tsgo_env = vim.fn.getenv("TSGO")
		if tsgo_env == "0" or tsgo_env == "false" then
			useTSGo = false
		end

		if useTSGo then
			local tsgo_bin = root_dir .. "/node_modules/.bin/tsgo"
			if executable(tsgo_bin) then
				vim.lsp.config("tsgo", {
					cmd = { tsgo_bin, "--lsp", "--stdio" },
					capabilities = capabilities,
				})

				vim.lsp.enable("tsgo")
			end

			return
		end

		local node_path = nil
		if file_exists(root_dir .. "/src/cli/tsserverNode") then
			node_path = root_dir .. "/src/cli/tsserverNode"
		end

		local mason_vtsls = vim.fn.stdpath("data") .. "/mason/bin/vtsls"
		local has_mason_vtsls = executable(mason_vtsls)
		local has_global_vtsls = executable("vtsls")

		vim.lsp.config("vtsls", {
			cmd = has_mason_vtsls and { mason_vtsls, "--stdio" } or { "vtsls", "--stdio" },
			capabilities = capabilities,
			settings = {
				vtsls = {
					autoUseWorkspaceTsdk = true,
				},
				typescript = {
					format = {
						enable = false,
					},
					inlayHints = {
						parameterNames = { enabled = "all" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
					tsserver = {
						nodePath = node_path,
						maxTsServerMemory = 24576,
					},
				},
			},
		})

		if has_mason_vtsls or has_global_vtsls then
			vim.lsp.enable("vtsls")
		end
	end,

	init = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end

				if client.name == "biome" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("BiomeFixAll" .. args.buf, {
							clear = true,
						}),
						buffer = args.buf,

						callback = function()
							vim.lsp.buf.code_action({
								context = {
									---@diagnostic disable-next-line: assign-type-mismatch
									only = { "source.fixAll.biome" },
									diagnostics = {},
								},

								apply = true,
							})
						end,
					})
				end

				if client.name == "eslint" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("EslintFixAll" .. args.buf, {
							clear = true,
						}),
						buffer = args.buf,

						callback = function()
							vim.lsp.buf.code_action({
								context = {
									---@diagnostic disable-next-line: assign-type-mismatch
									only = { "source.fixAll.eslint" },
									diagnostics = {},
								},

								apply = true,
							})
						end,
					})
				end
			end,
		})
	end,
}
