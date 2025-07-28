return {
  "zbirenbaum/copilot.lua",
  enabled = true,
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-l>",
          dismiss = "<C-x>",
        },
      },
    })
  end,
}
