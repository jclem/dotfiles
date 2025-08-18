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
}
