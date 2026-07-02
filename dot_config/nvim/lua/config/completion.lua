local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup({
    completion = {
        documentation = { auto_show = true },
        ghost_text = { enabled = true },
        menu = {
            draw = {
                cursorline_priority = 0,
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local kind_icon = require("mini.icons").get("lsp", ctx.kind)
                            return kind_icon
                        end,

                        highlight = function(ctx)
                            local _, hl = require("mini.icons").get("lsp", ctx.kind)
                            return hl
                        end,
                    },
                    kind = {
                        highlight = function(ctx)
                            local _, hl = require("mini.icons").get("lsp", ctx.kind)
                            return hl
                        end,
                    },
                    label = {
                        highlight = function(ctx)
                            local _, hl = require("mini.icons").get("lsp", ctx.kind)
                            return hl
                        end,
                    },
                },
            },
        },
    },
    fuzzy = { implementation = "rust" },
    signature = { enabled = true },
})
