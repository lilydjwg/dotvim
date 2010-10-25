" Colorscheme created with ColorSchemeEditor v1.2.2
" Name: lilydjwg
" Maintainer: lilydjwg
" Last Change: 2009年7月24日
set background=light
if version > 580
	highlight clear
	if exists("syntax_on")
		syntax reset
	endif
endif
let g:colors_name = "lilydjwg_purple_1.1"

if v:version >= 700
	highlight CursorColumn guibg=#B680FF gui=NONE
	highlight CursorLine guibg=#B680FF gui=NONE
	highlight Pmenu guibg=plum1 gui=NONE
	highlight PmenuSel guibg=grey gui=NONE
	highlight PmenuSbar guibg=grey gui=NONE
	highlight PmenuThumb gui=reverse
	highlight TabLine guibg=lightgrey gui=underline
	highlight TabLineFill gui=reverse
	highlight TabLineSel gui=bold
	if has('spell')
		highlight SpellBad gui=undercurl
		highlight SpellCap gui=undercurl
		highlight SpellLocal gui=undercurl
		highlight SpellRare gui=undercurl
	endif
endif
highlight Cursor guibg=#67F9FF gui=NONE
highlight CursorIM gui=NONE
highlight DiffAdd guibg=lightblue gui=NONE
highlight DiffChange guibg=plum1 gui=NONE
highlight DiffDelete guifg=blue guibg=lightcyan gui=bold
highlight DiffText guibg=red gui=bold
highlight Directory guifg=blue gui=NONE
highlight ErrorMsg guifg=white guibg=red gui=NONE
highlight FoldColumn guifg=darkblue guibg=grey gui=NONE
highlight Folded guifg=darkblue guibg=lightgrey gui=NONE
highlight IncSearch gui=reverse
highlight LineNr guifg=#FF00EA gui=NONE
highlight MatchParen guibg=cyan gui=NONE
highlight ModeMsg gui=bold
highlight MoreMsg guifg=seagreen gui=bold
highlight NonText guifg=blue gui=bold
highlight Normal guifg=#8021FF guibg=#DEA7FF gui=NONE
highlight Question guifg=seagreen gui=bold
highlight Search guibg=yellow gui=NONE
highlight SignColumn guifg=darkblue guibg=grey gui=NONE
highlight SpecialKey guifg=blue gui=NONE
highlight StatusLine gui=bold,reverse
highlight StatusLineNC gui=reverse
highlight Title guifg=#007cff gui=bold
highlight VertSplit gui=reverse
highlight Visual guibg=lightgrey gui=NONE
highlight VisualNOS gui=bold,underline
highlight WarningMsg guifg=red gui=NONE
highlight WildMenu guifg=black guibg=yellow gui=NONE
highlight link Boolean Constant
highlight link Character Constant
highlight Comment guifg=#5D625E gui=NONE
highlight link Conditional Statement
highlight Constant guifg=#2A8E00 guibg=bg gui=NONE
highlight link Debug Special
highlight link Define PreProc
highlight link Delimiter Special
highlight Error guifg=white guibg=red gui=NONE
highlight link Exception Statement
highlight link Float Constant
highlight link Function Identifier
highlight Identifier guifg=#b0ff33 gui=bold
highlight Ignore guifg=bg guibg=bg gui=NONE
highlight link Include PreProc
highlight link Keyword Statement
highlight link Label Statement
highlight link Macro PreProc
highlight link Number Constant
highlight link Operator Statement
highlight link PreCondit PreProc
highlight PreProc guifg=purple gui=NONE
highlight link Repeat Statement
highlight Special guifg=slateblue gui=NONE
highlight link SpecialChar Special
highlight link SpecialComment Special
highlight Statement guifg=#228B00 gui=bold
highlight link StorageClass Type
highlight link String Constant
highlight link Structure Type
highlight link Tag Special
highlight Todo guifg=blue guibg=yellow gui=NONE
highlight Type guifg=#fbfbfb gui=bold
highlight link Typedef Type
highlight Underlined guifg=#006C71 gui=underline


"ColorScheme metadata{{{
if v:version >= 700
	let g:lilydjwg_Metadata = {
				\"Palette" : "black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90",
				\"Last Change" : "2009年7月24日",
				\"Name" : "lilydjwg",
				\}
endif
"}}}
" vim:set foldmethod=marker expandtab filetype=vim:
