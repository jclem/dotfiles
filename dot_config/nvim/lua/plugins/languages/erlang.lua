return {
	"neovim/nvim-lspconfig",
	opts = function()
		local function erlang_root_dir(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local root_markers = { "rebar.config", "erlang.mk", ".git" }
			local root = vim.fs.root(fname, root_markers)
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
		local mason_erlangls = vim.fn.stdpath("data") .. "/mason/bin/erlang_ls"
		local erlangls_cmd = vim.fn.executable(mason_erlangls) == 1 and { mason_erlangls } or { "erlang_ls" }

		vim.lsp.config("erlangls", {
			cmd = erlangls_cmd,
			filetypes = { "erlang" },
			root_dir = erlang_root_dir,
			workspace_required = false,
		})
		vim.lsp.enable("erlangls")
	end,
}
