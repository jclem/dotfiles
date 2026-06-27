return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/codex.nvim",
    name = "codex.nvim",
    lazy = false,
    opts = {
      auto_start = true,
      codex_executable = "codex",
    },
    config = function(_, opts)
      require("codex").setup(opts)
    end,
  },
}
