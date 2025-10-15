return {
	"neovim/nvim-lspconfig",
	opts = function()
		local util = require("lspconfig.util")
		local root_dir = util.root_pattern(".git")(vim.fn.getcwd()) or vim.fn.getcwd()

		vim.lsp.enable('biome')
		vim.lsp.enable('eslint')

		-- Checks if a file exists
		-- @param path string
		local function file_exists(path)
			return vim.fn.filereadable(vim.fn.expand(path)) == 1
		end

		local useTSGo = false
		if file_exists(root_dir .. "/node_modules/@typescript/native-preview/package.json") then
			useTSGo = true
		end

		if useTSGo then
			vim.lsp.config('tsgo', {
				cmd = { root_dir .. '/node_modules/.bin/tsgo', '--lsp', '--stdio' }
			})

			vim.lsp.enable('tsgo')
		else
			local nodePath = nil
			if file_exists(root_dir .. "/src/cli/tsserverNode") then
				nodePath = root_dir .. "/src/cli/tsserverNode"
			end

			vim.lsp.config('vtsls', {
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
						nodePath = nodePath,
						maxTsServerMemory = 24576,
					},
				},
			})

			vim.lsp.enable('vtsls')
		end
	end,

	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("tsgo_autostart", { clear = true }),
			pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			callback = function(args)
				for _, c in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
					if c.name == "tsgo" then
						return
					end
				end
				vim.cmd("LspStart tsgo")
			end,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end

				if client.name == "biome" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("BiomeFixAll", {
							clear = true,
						}),

						callback = function()
							vim.lsp.buf.code_action({
								context = {
									---@diagnostic disable-next-line: assign-type-mismatch
									only = { "source.fixAll.biome" },
									diagnostics = {},
								},

								apply = true
							})
						end
					})
				end

				if client.name == "eslint" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("EslintFixAll", {
							clear = true,
						}),

						callback = function()
							vim.lsp.buf.code_action({
								context = {
									---@diagnostic disable-next-line: assign-type-mismatch
									only = { "source.fixAll.eslint" },
									diagnostics = {},
								},

								apply = true
							})
						end
					})
				end
			end,
		})
	end
}
