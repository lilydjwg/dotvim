scriptencoding utf-8
" 本配色方案由 gui2term.py 程序增加彩色终端支持。
" Colorscheme created with ColorSchemeEditor v1.2.2
" Name: pink
" Maintainer: lilydjwg <lilydjwg@gmail.com>
" Version: 1.2

set background=light
if version > 580
	highlight clear
	if exists("syntax_on")
		syntax reset
	endif
endif
let g:colors_name = "pink_lily"

if v:version >= 700
	highlight CursorColumn guibg=#ffd7af gui=NONE ctermfg=16 ctermbg=223 cterm=none
	highlight CursorLine guibg=#ffd78f gui=NONE ctermbg=222 cterm=none
	highlight CursorLineNr guifg=#5f5fff guibg=#ffd78f gui=NONE ctermfg=63 ctermbg=222 cterm=none
	highlight Pmenu guifg=#444444 guibg=#ffafff gui=NONE ctermfg=238 ctermbg=219 cterm=none
	highlight PmenuSel guifg=#00008f guibg=#FF99FF gui=bold ctermfg=18 ctermbg=213 cterm=bold
	highlight PmenuSbar guifg=#444444 guibg=#FF99FF gui=NONE ctermfg=238 ctermbg=213 cterm=none
	highlight PmenuThumb guifg=#444444 guibg=#FF6BFF gui=NONE ctermfg=238 ctermbg=207 cterm=none
	highlight TabLine guifg=#444444 guibg=#ffafff gui=NONE ctermfg=238 ctermbg=219 cterm=none
	highlight TabLineFill guifg=#ffafff guibg=#ffafff gui=NONE ctermfg=219 ctermbg=219 cterm=none
	highlight TabLineSel guifg=#000000 guibg=#ffd7ff gui=NONE ctermfg=16 ctermbg=225 cterm=none
	if has('spell')
		highlight SpellBad guifg=#444444 guibg=#ff0000 gui=NONE ctermfg=238 ctermbg=196 cterm=none
		highlight SpellCap guibg=#9e9e9e gui=NONE ctermfg=16 ctermbg=247 cterm=none
		highlight SpellLocal guibg=#ffd7d7 gui=NONE ctermfg=16 ctermbg=224 cterm=none
		highlight SpellRare guibg=#ffff8f gui=NONE ctermfg=16 ctermbg=228 cterm=none
	endif
endif
highlight Cursor guifg=bg guibg=#ff5fff gui=NONE ctermfg=225 ctermbg=207 cterm=none
highlight CursorIM gui=NONE ctermfg=16 ctermbg=225 cterm=none
highlight DiffAdd guifg=#5fd7af guibg=#0000ff gui=NONE ctermfg=79 ctermbg=21 cterm=none
highlight DiffChange guifg=#000000 guibg=#5fff5f gui=NONE ctermfg=16 ctermbg=83 cterm=none
highlight DiffDelete guifg=#5fd7af guibg=#af0000 gui=NONE ctermfg=79 ctermbg=124 cterm=none
highlight DiffText guifg=#000000 guibg=#d7ff00 gui=NONE ctermfg=16 ctermbg=190 cterm=none
highlight Directory guifg=#008f00 gui=NONE ctermfg=28 ctermbg=225 cterm=none
highlight ErrorMsg guifg=#333333 guibg=#FF7C7C gui=bold ctermfg=236 ctermbg=210 cterm=bold
highlight FoldColumn guifg=#5f5fff guibg=#eeeeee gui=NONE ctermfg=63 ctermbg=254 cterm=none
highlight Folded guifg=#444444 guibg=#FFE8FF gui=NONE ctermfg=238 ctermbg=225 cterm=none
highlight IncSearch guibg=#ffff00 gui=NONE ctermfg=16 ctermbg=226 cterm=none
highlight LineNr guifg=#5f5fff guibg=#ffff8f gui=NONE ctermfg=63 ctermbg=228 cterm=none
highlight MatchParen guibg=#FFFFFF gui=NONE ctermfg=16 ctermbg=231 cterm=none
highlight ModeMsg guibg=#ffff00 gui=bold ctermfg=16 ctermbg=226 cterm=bold
highlight MoreMsg guifg=#000000 guibg=#ffff00 gui=bold ctermfg=16 ctermbg=226 cterm=bold
highlight NonText guifg=#444444 guibg=#ffd7ff gui=NONE ctermfg=238 ctermbg=225 cterm=none
highlight Normal guifg=#444444 guibg=#ffd7ff gui=NONE ctermfg=238 ctermbg=225 cterm=none
highlight Question guifg=#005fff gui=bold ctermfg=27 ctermbg=225 cterm=bold
highlight Search guifg=Black guibg=#ffff00 gui=NONE ctermfg=16 ctermbg=226 cterm=none
highlight SignColumn guifg=Cyan guibg=Grey gui=NONE ctermfg=51 ctermbg=250 cterm=none
highlight SpecialKey guifg=#ff0000 gui=NONE ctermfg=196 ctermbg=225 cterm=none
highlight StatusLine guifg=#000000 guibg=#ffafff gui=NONE ctermfg=16 ctermbg=219 cterm=none
highlight StatusLineNC guifg=#444444 guibg=#ffafff gui=NONE ctermfg=238 ctermbg=219 cterm=none
highlight Title guifg=#00008f gui=bold ctermfg=18 ctermbg=none cterm=bold
highlight VertSplit guifg=#FFAFFF guibg=#FFAFFF gui=NONE ctermfg=219 ctermbg=219 cterm=none
highlight Visual guibg=#ffd700 gui=NONE ctermfg=16 ctermbg=220 cterm=none
highlight VisualNOS gui=bold,underline ctermfg=16 ctermbg=225 cterm=bold,underline
highlight WarningMsg guifg=#000000 guibg=#ffff00 gui=NONE ctermfg=16 ctermbg=226 cterm=none
highlight WildMenu guifg=#5fffff guibg=#00af5f gui=bold ctermfg=87 ctermbg=35 cterm=bold
highlight link Boolean Constant
highlight link Character Constant
highlight Comment guifg=#FC6FE8 guibg=bg gui=italic ctermfg=206 ctermbg=225 cterm=NONE
highlight link Conditional Statement
highlight Constant guifg=#ff00a0 gui=NONE ctermfg=199 ctermbg=225 cterm=none
highlight link Debug Special
highlight link Define PreProc
highlight link Delimiter Special
highlight Error guifg=#af5f00 guibg=bg gui=NONE ctermfg=130 ctermbg=225 cterm=none
highlight link Exception Statement
highlight link Float Number
highlight link Function Identifier
highlight Identifier guifg=#008faf gui=NONE ctermfg=31 ctermbg=225 cterm=none
highlight Ignore guifg=bg gui=NONE ctermfg=225 ctermbg=225 cterm=none
highlight link Include PreProc
highlight link Keyword Statement
highlight link Label Statement
highlight link Macro PreProc
highlight Number guifg=#00AB11 gui=NONE ctermfg=34 ctermbg=225 cterm=none
highlight link Operator Statement
highlight link PreCondit PreProc
highlight PreProc guifg=#005fd7 gui=NONE ctermfg=26 ctermbg=225 cterm=none
highlight link Repeat Statement
highlight Special guifg=#FF00EC gui=NONE ctermfg=201 ctermbg=225 cterm=none
highlight SpecialChar guifg=#FD4040 gui=NONE ctermfg=203 ctermbg=225 cterm=none
highlight link SpecialComment Special
highlight Statement guifg=#FE391B gui=NONE ctermfg=202 ctermbg=225 cterm=none
highlight link StorageClass Type
highlight String guifg=#BB46FF gui=NONE ctermfg=135 ctermbg=225 cterm=none
highlight link Structure Type
highlight link Tag Special
highlight Todo guifg=Blue guibg=#ffffaf gui=NONE ctermfg=21 ctermbg=229 cterm=none
highlight Type guifg=#0000FF gui=NONE ctermfg=21 ctermbg=225 cterm=none
highlight link Typedef Type
highlight Underlined guifg=#005faf gui=bold ctermfg=25 ctermbg=225 cterm=bold


"ColorScheme metadata{{{
if v:version >= 700
	let g:pink_Metadata = {
				\"Palette" : "black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90",
				\"Maintainer" : "lilydjwg",
				\"Name" : "pink",
				\"Last Change" : "2009年8月7日",
				\"Version" : "1.0",
				\"Email" : "lilydjwg@gmail.com",
				\}
endif
"}}}
" vim:set foldmethod=marker expandtab filetype=vim:
