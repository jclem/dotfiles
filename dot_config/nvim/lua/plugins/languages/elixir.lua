return {
	"neovim/nvim-lspconfig",
	opts = function()
		local selected_lsp = vim.g.elixir_lsp or "elixirls"
		if selected_lsp ~= "elixirls" and selected_lsp ~= "expert" then
			vim.notify(
				string.format("Invalid vim.g.elixir_lsp=%q. Falling back to elixirls.", selected_lsp),
				vim.log.levels.WARN
			)
			selected_lsp = "elixirls"
		end

		local function elixir_root_dir(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local root = vim.fs.root(fname, { "mix.exs", ".git" })
			if root then
				on_dir(root)
				return
			end

			local cwd = vim.uv.cwd() or vim.fn.getcwd()
			local cwd_mix = vim.fs.find("mix.exs", { path = cwd, upward = true })[1]
			if cwd_mix then
				on_dir(vim.fs.dirname(cwd_mix))
				return
			end

			on_dir(cwd)
		end

		local mason_expert = vim.fn.stdpath("data") .. "/mason/bin/expert"
		local expert_cmd = vim.fn.executable(mason_expert) == 1 and { mason_expert, "--stdio" } or { "expert", "--stdio" }
		local expert_install_dir = vim.fn.stdpath("data") .. "/expert"

		vim.fn.mkdir(expert_install_dir, "p")
		vim.lsp.config("expert", {
			cmd = expert_cmd,
			cmd_env = { EXPERT_INSTALL_DIR = expert_install_dir },
			filetypes = { "elixir", "eelixir", "heex" },
			root_dir = elixir_root_dir,
			workspace_required = false,
			enabled = selected_lsp == "expert",
		})
		if selected_lsp == "expert" then
			vim.lsp.enable("expert")
		end

		local mason_elixirls = vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh"
		local elixirls_cmd = vim.fn.executable(mason_elixirls) == 1 and { mason_elixirls } or { "elixir-ls" }
		vim.lsp.config("elixirls", {
			cmd = elixirls_cmd,
			filetypes = { "elixir", "eelixir", "heex" },
			root_dir = elixir_root_dir,
			workspace_required = false,
			enabled = selected_lsp == "elixirls",
		})
		if selected_lsp == "elixirls" then
			vim.lsp.enable("elixirls")
		end
	end,
}
