vim.cmd("highlight clear")
vim.g.colors_name = "folio"

local palettes = {
	dark = {
		bg0 = "#1C1B18",
		bg1 = "#252420",
		bg2 = "#302E29",
		bg3 = "#3D3A34",
		fg0 = "#D5D2C8",
		fg1 = "#B0AD9F",
		fg2 = "#8A8778",
		fg3 = "#5E5B50",
		accent = "#C4A882",
		highlight = "#3A3428",
		diffAdd = "#2A3325",
		diffDel = "#362525",
		error = "#C86060",
		warn = "#C4A050",
		red = "#C86060",
		green = "#8AAA70",
		yellow = "#C4A050",
		blue = "#7099BB",
		magenta = "#A882A8",
		cyan = "#70A8A0",
		brRed = "#D88080",
		brGreen = "#A0BB88",
		brYellow = "#D4B468",
		brBlue = "#88AACC",
		brMagenta = "#BB99BB",
		brCyan = "#88BBAA",
	},
	light = {
		bg0 = "#FFFCF5",
		bg1 = "#F4F1EA",
		bg2 = "#E8E5DD",
		bg3 = "#DDDAD2",
		fg0 = "#2B2924",
		fg1 = "#4D4A43",
		fg2 = "#6E6A5F",
		fg3 = "#9C9889",
		accent = "#8B7355",
		highlight = "#EDE4D0",
		diffAdd = "#D5E0C8",
		diffDel = "#E8D0C8",
		error = "#A04040",
		warn = "#8B7040",
		red = "#A04040",
		green = "#5A7A4A",
		yellow = "#8B7040",
		blue = "#4A6A8B",
		magenta = "#7A5A7A",
		cyan = "#4A7A7A",
		brRed = "#B85050",
		brGreen = "#6E8B5E",
		brYellow = "#A08550",
		brBlue = "#5E7E9E",
		brMagenta = "#8B6E8B",
		brCyan = "#5E8B8B",
	},
}

local p = palettes[vim.o.background] or palettes.dark

local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- UI
hi("Normal", { fg = p.fg0, bg = p.bg0 })
hi("NormalFloat", { fg = p.fg0, bg = p.bg1 })
hi("NormalNC", { fg = p.fg0, bg = p.bg0 })
hi("FloatBorder", { fg = p.fg3, bg = p.bg1 })
hi("FloatTitle", { fg = p.accent, bg = p.bg1, bold = true })
hi("CursorLine", { bg = p.bg1 })
hi("CursorColumn", { bg = p.bg1 })
hi("ColorColumn", { bg = p.bg1 })
hi("Visual", { bg = p.highlight })
hi("VisualNOS", { bg = p.highlight })
hi("Cursor", { fg = p.bg0, bg = p.fg0 })
hi("lCursor", { fg = p.bg0, bg = p.fg0 })
hi("CursorIM", { fg = p.bg0, bg = p.fg0 })
hi("TermCursor", { fg = p.bg0, bg = p.fg0 })
hi("TermCursorNC", { fg = p.bg0, bg = p.fg3 })

hi("LineNr", { fg = p.fg3 })
hi("CursorLineNr", { fg = p.accent, bold = true })
hi("SignColumn", { fg = p.fg3, bg = p.bg0 })
hi("FoldColumn", { fg = p.fg3, bg = p.bg0 })
hi("Folded", { fg = p.fg2, bg = p.bg2 })
hi("VertSplit", { fg = p.bg3 })
hi("WinSeparator", { fg = p.bg3 })

hi("StatusLine", { fg = p.fg1, bg = p.bg2 })
hi("StatusLineNC", { fg = p.fg3, bg = p.bg1 })
hi("TabLine", { fg = p.fg2, bg = p.bg2 })
hi("TabLineFill", { bg = p.bg1 })
hi("TabLineSel", { fg = p.fg0, bg = p.bg0, bold = true })
hi("WinBar", { fg = p.fg1, bg = p.bg0, bold = true })
hi("WinBarNC", { fg = p.fg3, bg = p.bg0 })

hi("Pmenu", { fg = p.fg1, bg = p.bg1 })
hi("PmenuSel", { fg = p.fg0, bg = p.bg3 })
hi("PmenuSbar", { bg = p.bg2 })
hi("PmenuThumb", { bg = p.fg3 })

hi("Search", { fg = p.bg0, bg = p.accent })
hi("IncSearch", { fg = p.bg0, bg = p.yellow })
hi("CurSearch", { fg = p.bg0, bg = p.yellow, bold = true })
hi("Substitute", { fg = p.bg0, bg = p.red })

hi("MatchParen", { fg = p.accent, bold = true, underline = true })
hi("NonText", { fg = p.fg3 })
hi("SpecialKey", { fg = p.fg3 })
hi("Whitespace", { fg = p.bg3 })
hi("EndOfBuffer", { fg = p.bg2 })
hi("Directory", { fg = p.blue })
hi("Title", { fg = p.accent, bold = true })
hi("Question", { fg = p.green })
hi("MoreMsg", { fg = p.green })
hi("ModeMsg", { fg = p.fg1, bold = true })
hi("ErrorMsg", { fg = p.error, bold = true })
hi("WarningMsg", { fg = p.warn })
hi("WildMenu", { fg = p.bg0, bg = p.accent })

-- Diagnostics
hi("DiagnosticError", { fg = p.error })
hi("DiagnosticWarn", { fg = p.warn })
hi("DiagnosticInfo", { fg = p.blue })
hi("DiagnosticHint", { fg = p.cyan })
hi("DiagnosticOk", { fg = p.green })
hi("DiagnosticUnderlineError", { sp = p.error, undercurl = true })
hi("DiagnosticUnderlineWarn", { sp = p.warn, undercurl = true })
hi("DiagnosticUnderlineInfo", { sp = p.blue, undercurl = true })
hi("DiagnosticUnderlineHint", { sp = p.cyan, undercurl = true })
hi("DiagnosticVirtualTextError", { fg = p.error, bg = p.bg1 })
hi("DiagnosticVirtualTextWarn", { fg = p.warn, bg = p.bg1 })
hi("DiagnosticVirtualTextInfo", { fg = p.blue, bg = p.bg1 })
hi("DiagnosticVirtualTextHint", { fg = p.cyan, bg = p.bg1 })

-- Diff
hi("DiffAdd", { bg = p.diffAdd })
hi("DiffChange", { bg = p.highlight })
hi("DiffDelete", { bg = p.diffDel })
hi("DiffText", { bg = p.diffAdd, bold = true })
hi("Added", { fg = p.green })
hi("Changed", { fg = p.yellow })
hi("Removed", { fg = p.red })

-- Spell
hi("SpellBad", { sp = p.error, undercurl = true })
hi("SpellCap", { sp = p.warn, undercurl = true })
hi("SpellLocal", { sp = p.blue, undercurl = true })
hi("SpellRare", { sp = p.magenta, undercurl = true })

-- Syntax
hi("Comment", { fg = p.fg3, italic = true })
hi("Constant", { fg = p.magenta })
hi("String", { fg = p.green })
hi("Character", { fg = p.green })
hi("Number", { fg = p.magenta })
hi("Boolean", { fg = p.magenta })
hi("Float", { fg = p.magenta })
hi("Identifier", { fg = p.fg0 })
hi("Function", { fg = p.blue })
hi("Statement", { fg = p.red })
hi("Conditional", { fg = p.red })
hi("Repeat", { fg = p.red })
hi("Label", { fg = p.red })
hi("Operator", { fg = p.fg1 })
hi("Keyword", { fg = p.red })
hi("Exception", { fg = p.red })
hi("PreProc", { fg = p.yellow })
hi("Include", { fg = p.red })
hi("Define", { fg = p.yellow })
hi("Macro", { fg = p.yellow })
hi("PreCondit", { fg = p.yellow })
hi("Type", { fg = p.yellow })
hi("StorageClass", { fg = p.yellow })
hi("Structure", { fg = p.yellow })
hi("Typedef", { fg = p.yellow })
hi("Special", { fg = p.cyan })
hi("SpecialChar", { fg = p.cyan })
hi("Tag", { fg = p.accent })
hi("Delimiter", { fg = p.fg2 })
hi("SpecialComment", { fg = p.fg3, italic = true })
hi("Debug", { fg = p.red })
hi("Underlined", { underline = true })
hi("Error", { fg = p.error })
hi("Todo", { fg = p.accent, bold = true })

-- Treesitter
hi("@variable", { fg = p.fg0 })
hi("@variable.builtin", { fg = p.magenta, italic = true })
hi("@variable.parameter", { fg = p.fg1 })
hi("@variable.member", { fg = p.fg0 })
hi("@constant", { fg = p.magenta })
hi("@constant.builtin", { fg = p.magenta })
hi("@constant.macro", { fg = p.magenta })
hi("@module", { fg = p.yellow })
hi("@label", { fg = p.accent })
hi("@string", { fg = p.green })
hi("@string.escape", { fg = p.cyan })
hi("@string.special", { fg = p.cyan })
hi("@character", { fg = p.green })
hi("@number", { fg = p.magenta })
hi("@boolean", { fg = p.magenta })
hi("@float", { fg = p.magenta })
hi("@function", { fg = p.blue })
hi("@function.builtin", { fg = p.blue, italic = true })
hi("@function.call", { fg = p.blue })
hi("@function.macro", { fg = p.yellow })
hi("@function.method", { fg = p.blue })
hi("@function.method.call", { fg = p.blue })
hi("@constructor", { fg = p.yellow })
hi("@operator", { fg = p.fg1 })
hi("@keyword", { fg = p.red })
hi("@keyword.function", { fg = p.red })
hi("@keyword.operator", { fg = p.red })
hi("@keyword.import", { fg = p.red })
hi("@keyword.return", { fg = p.red })
hi("@keyword.exception", { fg = p.red })
hi("@keyword.conditional", { fg = p.red })
hi("@keyword.repeat", { fg = p.red })
hi("@type", { fg = p.yellow })
hi("@type.builtin", { fg = p.yellow, italic = true })
hi("@type.qualifier", { fg = p.red })
hi("@attribute", { fg = p.accent })
hi("@property", { fg = p.fg0 })
hi("@punctuation.bracket", { fg = p.fg2 })
hi("@punctuation.delimiter", { fg = p.fg2 })
hi("@punctuation.special", { fg = p.cyan })
hi("@comment", { fg = p.fg3, italic = true })
hi("@comment.documentation", { fg = p.fg3, italic = true })
hi("@comment.todo", { fg = p.accent, bold = true })
hi("@comment.note", { fg = p.blue, bold = true })
hi("@comment.warning", { fg = p.warn, bold = true })
hi("@comment.error", { fg = p.error, bold = true })
hi("@tag", { fg = p.red })
hi("@tag.attribute", { fg = p.accent })
hi("@tag.delimiter", { fg = p.fg2 })
hi("@markup.heading", { fg = p.accent, bold = true })
hi("@markup.italic", { italic = true })
hi("@markup.strong", { bold = true })
hi("@markup.strikethrough", { strikethrough = true })
hi("@markup.underline", { underline = true })
hi("@markup.raw", { fg = p.cyan })
hi("@markup.link", { fg = p.blue, underline = true })
hi("@markup.link.url", { fg = p.blue, underline = true })
hi("@markup.link.label", { fg = p.blue })
hi("@markup.list", { fg = p.accent })

-- LSP semantic tokens
hi("@lsp.type.class", { fg = p.yellow })
hi("@lsp.type.decorator", { fg = p.accent })
hi("@lsp.type.enum", { fg = p.yellow })
hi("@lsp.type.enumMember", { fg = p.magenta })
hi("@lsp.type.function", { fg = p.blue })
hi("@lsp.type.interface", { fg = p.yellow })
hi("@lsp.type.macro", { fg = p.yellow })
hi("@lsp.type.method", { fg = p.blue })
hi("@lsp.type.namespace", { fg = p.yellow })
hi("@lsp.type.parameter", { fg = p.fg1 })
hi("@lsp.type.property", { fg = p.fg0 })
hi("@lsp.type.struct", { fg = p.yellow })
hi("@lsp.type.type", { fg = p.yellow })
hi("@lsp.type.typeParameter", { fg = p.yellow })
hi("@lsp.type.variable", { fg = p.fg0 })

-- Git signs
hi("GitSignsAdd", { fg = p.green })
hi("GitSignsChange", { fg = p.yellow })
hi("GitSignsDelete", { fg = p.red })

-- Telescope
hi("TelescopeNormal", { fg = p.fg1, bg = p.bg1 })
hi("TelescopeBorder", { fg = p.fg3, bg = p.bg1 })
hi("TelescopePromptNormal", { fg = p.fg0, bg = p.bg2 })
hi("TelescopePromptBorder", { fg = p.bg2, bg = p.bg2 })
hi("TelescopePromptTitle", { fg = p.bg0, bg = p.accent, bold = true })
hi("TelescopePreviewTitle", { fg = p.bg0, bg = p.green, bold = true })
hi("TelescopeResultsTitle", { fg = p.bg1, bg = p.bg1 })
hi("TelescopeSelection", { fg = p.fg0, bg = p.bg3 })
hi("TelescopeMatching", { fg = p.accent, bold = true })

-- Snacks
hi("SnacksPickerDir", { fg = p.fg3 })

-- Mini
hi("MiniStatuslineFilename", { fg = p.fg1, bg = p.bg2 })
hi("MiniStatuslineDevinfo", { fg = p.fg1, bg = p.bg2 })
hi("MiniStatuslineFileinfo", { fg = p.fg1, bg = p.bg2 })
hi("MiniStatuslineModeNormal", { fg = p.bg0, bg = p.accent, bold = true })
hi("MiniStatuslineModeInsert", { fg = p.bg0, bg = p.green, bold = true })
hi("MiniStatuslineModeVisual", { fg = p.bg0, bg = p.magenta, bold = true })
hi("MiniStatuslineModeReplace", { fg = p.bg0, bg = p.red, bold = true })
hi("MiniStatuslineModeCommand", { fg = p.bg0, bg = p.yellow, bold = true })

-- Indent / scope
hi("MiniIndentscopeSymbol", { fg = p.fg3 })
hi("IblIndent", { fg = p.bg2 })
hi("IblScope", { fg = p.fg3 })

-- Lazy
hi("LazyButton", { fg = p.fg1, bg = p.bg2 })
hi("LazyButtonActive", { fg = p.bg0, bg = p.accent, bold = true })
hi("LazyH1", { fg = p.bg0, bg = p.accent, bold = true })
