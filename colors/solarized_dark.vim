" Colorscheme created with ColorSchemeEditor v1.2.2
"Name: solarized
"Maintainer: 
"Last Change: 2011  8月 24
set background=dark
if version > 580
	highlight clear
	if exists("syntax_on")
		syntax reset
	endif
endif
let g:colors_name = "solarized_dark"

if v:version >= 700
highlight CursorColumn guibg=#073642 gui=NONE ctermbg=236 cterm=NONE
highlight CursorLine guibg=#073642 gui=NONE ctermbg=236 cterm=NONE
highlight Pmenu guifg=#839496 guibg=#073642 gui=reverse ctermfg=246 ctermbg=236 cterm=reverse
highlight PmenuSel guifg=#586e75 guibg=#eee8d5 gui=reverse ctermfg=242 ctermbg=254 cterm=reverse
highlight PmenuSbar guifg=#eee8d5 guibg=#839496 gui=reverse ctermfg=254 ctermbg=246 cterm=reverse
highlight PmenuThumb guifg=#839496 guibg=#002b36 gui=reverse ctermfg=246 ctermbg=235 cterm=reverse
highlight TabLine guifg=#839496 guibg=#073642 gui=NONE ctermfg=246 ctermbg=236 cterm=NONE
highlight TabLineFill guifg=#839496 guibg=#073642 gui=NONE ctermfg=246 ctermbg=236 cterm=NONE
highlight TabLineSel guifg=#586e75 guibg=#eee8d5 gui=reverse ctermfg=242 ctermbg=254 cterm=reverse
	if has('spell')
highlight SpellBad gui=undercurl cterm=undercurl
highlight SpellCap gui=undercurl cterm=undercurl
highlight SpellLocal gui=undercurl cterm=undercurl
highlight SpellRare gui=undercurl cterm=undercurl
	endif
endif
highlight Cursor guifg=#002b36 guibg=#839496 gui=NONE ctermfg=235 ctermbg=246 cterm=NONE
highlight CursorIM gui=NONE cterm=NONE
highlight DiffAdd guifg=#719e07 guibg=#073642 gui=bold ctermfg=106 ctermbg=236 cterm=bold
highlight DiffChange guifg=#b58900 guibg=#073642 gui=bold ctermfg=136 ctermbg=236 cterm=bold
highlight DiffDelete guifg=#dc322f guibg=#073642 gui=bold ctermfg=160 ctermbg=236 cterm=bold
highlight DiffText guifg=#268bd2 guibg=#073642 gui=bold ctermfg=32 ctermbg=236 cterm=bold
highlight Directory guifg=#268bd2 gui=NONE ctermfg=32 cterm=NONE
highlight ErrorMsg guifg=#dc322f guibg=#ffffff gui=reverse ctermfg=160 ctermbg=231 cterm=reverse
highlight FoldColumn guifg=#839496 guibg=#073642 gui=NONE ctermfg=246 ctermbg=236 cterm=NONE
highlight Folded guifg=#839496 guibg=#073642 ctermfg=246 ctermbg=236
highlight IncSearch guifg=#cb4b16 gui=standout ctermfg=166 cterm=standout
highlight LineNr guifg=#586e75 guibg=#073642 gui=NONE ctermfg=242 ctermbg=236 cterm=NONE
highlight MatchParen guifg=#dc322f guibg=#586e75 gui=bold ctermfg=160 ctermbg=242 cterm=bold
highlight ModeMsg guifg=#268bd2 gui=NONE ctermfg=32 cterm=NONE
highlight MoreMsg guifg=#268bd2 gui=NONE ctermfg=32 cterm=NONE
highlight NonText guifg=#657b83 gui=bold ctermfg=66 cterm=bold
highlight Normal guifg=#839496 guibg=#002b36 gui=NONE ctermfg=246 ctermbg=235 cterm=NONE
highlight Question guifg=#2aa198 gui=bold ctermfg=37 cterm=bold
highlight Search guifg=#b58900 gui=reverse ctermfg=136 cterm=reverse
highlight SignColumn guifg=#839496 guibg=grey gui=NONE ctermfg=246 ctermbg=250 cterm=NONE
highlight SpecialKey guifg=#d090ff ctermfg=177
highlight StatusLine guifg=#93a1a1 guibg=#073642 gui=reverse ctermfg=247 ctermbg=236 cterm=reverse
highlight StatusLineNC guifg=#657b83 guibg=#073642 gui=reverse ctermfg=66 ctermbg=236 cterm=reverse
highlight Title guifg=#cb4b16 gui=bold ctermfg=166 cterm=bold
highlight VertSplit guifg=#657b83 guibg=#657b83 gui=NONE ctermfg=66 ctermbg=66 cterm=NONE
highlight Visual guibg=#003d4c ctermbg=24
highlight WarningMsg guifg=#dc322f gui=bold ctermfg=160 cterm=bold
highlight WildMenu guifg=#eee8d5 guibg=#073642 gui=reverse ctermfg=254 ctermbg=236 cterm=reverse
highlight link Boolean Constant
highlight link Character Constant
highlight Comment guifg=#586e75 gui=italic ctermfg=242
highlight link Conditional Statement
highlight Constant guifg=#2aa198 gui=NONE ctermfg=37 cterm=NONE
highlight link Debug Special
highlight link Define PreProc
highlight link Delimiter Special
highlight Error guibg=#dc322f gui=bold ctermbg=160 cterm=bold
highlight link Exception Statement
highlight link Float Number
highlight link Function Identifier
highlight Identifier guifg=#268bd2 gui=NONE ctermfg=32 cterm=NONE
highlight Ignore gui=NONE cterm=NONE
highlight link Include PreProc
highlight link Keyword Statement
highlight link Label Statement
highlight link Macro PreProc
highlight link Number Constant
highlight link Operator Statement
highlight link PreCondit PreProc
highlight PreProc guifg=#cb4b16 gui=NONE ctermfg=166 cterm=NONE
highlight link Repeat Statement
highlight Special guifg=#dc322f gui=NONE ctermfg=160 cterm=NONE
highlight link SpecialChar Special
highlight link SpecialComment Special
highlight Statement guifg=#719e07 gui=NONE ctermfg=106 cterm=NONE
highlight link StorageClass Type
highlight link String Constant
highlight link Structure Type
highlight link Tag Special
highlight Todo guifg=#d33682 gui=bold ctermfg=162 cterm=bold
highlight Type guifg=#b58900 gui=NONE ctermfg=136 cterm=NONE
highlight link Typedef Type
highlight Underlined guifg=#6c71c4 gui=NONE ctermfg=62 cterm=NONE


"ColorScheme metadata{{{
if v:version >= 700
	let g:solarized_Metadata = {
				\"Palette" : "black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90",
				\"Last Change" : "2011  8月 24",
				\"Name" : "solarized",
				\}
endif
"}}}
" vim:set foldmethod=marker expandtab filetype=vim:
