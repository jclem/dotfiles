" Vim syntax file for Ghostty configuration
" Language: Ghostty Config

if exists("b:current_syntax")
  finish
endif

" Comments
syn match ghosttyComment "#.*$"

" Keys (everything before the = on a line)
syn match ghosttyKey "^\s*[^#=]\+\ze\s*="

" Values (everything after the = on a line)
syn match ghosttyValue "=\s*\zs.*$"

" Highlighting
hi def link ghosttyComment Comment
hi def link ghosttyKey Keyword
hi def link ghosttyValue String

let b:current_syntax = "ghostty"