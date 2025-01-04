return {
	"folke/trouble.nvim",
	enabled = true,
	lazy = false,
	cmd = { "Trouble" },
	opts = {
		warn_no_results = false,

		modes = {
			diagnostics = {
				auto_close = true,
				filter = { buf = 0 }
			},

			lsp_floating_types = {
				auto_jump = false,
				mode = "lsp_type_definitions",
				win = {
					type = "split",
				}
			},

			lsp_large = {
				mode = "lsp",
				win = {
					type = "split",
					relative = "editor",
					position = "right",
					size = 60,
				}
			}
		},
	},
	keys = {
		{ "<leader>ld", "<cmd>Trouble lsp_definitions toggle auto_jump=false focus=false<cr>",      desc = "Definitions" },
		{ "<leader>lD", "<cmd>Trouble lsp_definitions toggle auto_jump=true focus=true<cr>",        desc = "Definitions (Focus)" },
		{ "<leader>lt", "<cmd>Trouble lsp_type_definitions toggle auto_jump=false focus=false<cr>", desc = "Type Definitions" },
		{ "<leader>lT", "<cmd>Trouble lsp_type_definitions toggle auto_jump=true focus=true<cr>",   desc = "Type Definitions (Focus)" },
		{ "<leader>li", "<cmd>Trouble lsp_implementations toggle auto_jump=false focus=false<cr>",  desc = "Implementations" },
		{ "<leader>lI", "<cmd>Trouble lsp_implementations toggle auto_jump=true focus=true<cr>",    desc = "Implementations (Focus)" },
		{ "<leader>lr", "<cmd>Trouble lsp_references toggle auto_jump=false focus=false<cr>",       desc = "References" },
		{ "<leader>lR", "<cmd>Trouble lsp_references toggle auto_jump=true focus=true<cr>",         desc = "References (Focus)" },
		{ "<leader>ll", "<cmd>Trouble lsp toggle auto_jump=false focus=false<cr>",                  desc = "LSP" },
		{ "<leader>lL", "<cmd>Trouble lsp_large toggle auto_jump=false focus=true<cr>",             desc = "All (Focus)" },
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",                         desc = "Buffer Diagnostics" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>",                                      desc = "Workspace Diagnostics" },
		{
			"[q",
			function()
				if require("trouble").is_open() then
					require("trouble").prev({ skip_groups = true, jump = true })
				else
					local ok, err = pcall(vim.cmd.cprev)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
					end
				end
			end,
			desc = "Previous Trouble/Quickfix Item"
		},
		{
			"]q",
			function()
				if require("trouble").is_open() then
					require("trouble").next({ skip_groups = true, jump = true })
				else
					local ok, err = pcall(vim.cmd.cnext)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
					end
				end
			end,
			desc = "Next Trouble/Quickfix Item"
		},
	},
}
