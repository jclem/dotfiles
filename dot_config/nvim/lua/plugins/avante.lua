return {
  "yetone/avante.nvim",
  enabled = true,
  event = "VeryLazy",
  build = function()
    return "make"
  end,
  opts = {
    provider = "copilot",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "zbirenbaum/copilot.lua",
  },
}
