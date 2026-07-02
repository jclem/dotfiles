local cmp = require("blink.cmp")

local function kind_icon(ctx)
    if ctx.source_id == "copilot" then
        return ctx.kind_icon
    end

    return require("mini.icons").get("lsp", ctx.kind)
end

local function kind_highlight(ctx)
    if ctx.source_id == "copilot" then
        return ctx.kind_hl
    end

    local _, hl = require("mini.icons").get("lsp", ctx.kind)
    return hl
end

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
                        text = kind_icon,
                        highlight = kind_highlight,
                    },
                    kind = {
                        highlight = kind_highlight,
                    },
                    label = {
                        highlight = kind_highlight,
                    },
                },
            },
        },
    },
    fuzzy = { implementation = "rust" },
    sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
            copilot = {
                name = "Copilot",
                module = "blink-copilot",
                async = true,
                score_offset = 100,
                opts = {
                    kind_icon = "",
                    kind_hl = "MiniIconsPurple",
                },
            },
        },
    },
    signature = { enabled = true },
})
