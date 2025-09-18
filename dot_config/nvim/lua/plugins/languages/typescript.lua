return {
	"neovim/nvim-lspconfig",
	opts = function()
		local util = require("lspconfig.util")
		local root_dir = util.root_pattern(".git")(vim.fn.getcwd()) or vim.fn.getcwd()

		-- Checks if a file exists
		-- @param path string
		local function file_exists(path)
			return vim.fn.filereadable(vim.fn.expand(path)) == 1
		end

		local nodePath = nil
		if file_exists(root_dir .. "/src/cli/tsserverNode") then
			nodePath = root_dir .. "/src/cli/tsserverNode"
		end

		return {
			servers = {
				biome = {},
				eslint = {},
				vtsls = {
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
								nodePath = nodePath,
								maxTsServerMemory = 24576,
							},
						},
					},
				},
			},
		}
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
