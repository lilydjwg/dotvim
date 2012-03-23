" vim: tw=0 ts=4 sw=4
" Vim color file
" Version: 1.1
" Maintainer:	lilydjwg <lilydjwg@gmail.com>

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "darkBlue"

highlight Comment guifg=#6666ff ctermfg=63
highlight Constant guifg=#99cc33 ctermfg=112
highlight Cursor guifg=#ffffff guibg=#335577 ctermfg=231 ctermbg=24
highlight CursorIM guifg=#00aaff guibg=#ff66ff ctermfg=39 ctermbg=207
highlight CursorLine guibg=#223344 ctermbg=236 cterm=NONE
highlight CursorLineNr guifg=#446699 guibg=#223344 ctermfg=25 ctermbg=236 cterm=NONE
highlight DiffAdd guifg=#000000 guibg=#33ff33 ctermfg=16 ctermbg=46
highlight DiffChange guifg=#dddddd guibg=#5555cc ctermfg=253 ctermbg=62
highlight DiffDelete guifg=#000000 guibg=#ee6699 ctermfg=16 ctermbg=205
highlight DiffText guifg=#ffffff guibg=#8888ff ctermfg=231 ctermbg=105
highlight Directory guifg=#ff99ff ctermfg=213
highlight Error guifg=#ff0000 guibg=#111133 gui=underline ctermfg=196 ctermbg=17 cterm=underline
highlight ErrorMsg guifg=#ffff00 guibg=#0000ff ctermfg=226 ctermbg=21
highlight FoldColumn guifg=#0033ff guibg=#333333 ctermfg=21 ctermbg=236
highlight Folded guifg=#6666ff guibg=#223344 ctermfg=63 ctermbg=236
highlight Identifier guifg=#00a0e0 ctermfg=39
highlight Ignore gui=NONE cterm=NONE
highlight IncSearch guifg=#99ff99 guibg=#3454ff gui=bold,reverse ctermfg=120 ctermbg=27 cterm=bold,reverse
highlight LineNr guifg=#446699 ctermfg=25
highlight MatchParen guifg=#99ff99 guibg=#112233 ctermfg=120 ctermbg=234
highlight ModeMsg guifg=#aaaa3c guibg=#222211 gui=bold ctermfg=142 ctermbg=235 cterm=bold
highlight MoreMsg guifg=#ffff00 ctermfg=226
highlight NonText guifg=#8400ff guibg=#102030 ctermfg=93 ctermbg=234
highlight Normal guifg=#eeeeee guibg=#112233 ctermfg=255 ctermbg=234
highlight Pmenu guifg=#3366ff guibg=#111111 ctermfg=27 ctermbg=233
highlight PmenuSbar guibg=#113355 ctermbg=236
highlight PmenuSel guifg=#80ff00 guibg=#1a1a1a ctermfg=118 ctermbg=234
highlight PmenuThumb gui=reverse cterm=reverse
highlight PreProc guifg=#ff99ff ctermfg=213
highlight Question guifg=#009966 guibg=#113322 gui=bold ctermfg=29 ctermbg=236 cterm=bold
highlight Search guifg=#3404ff guibg=#ffff00 ctermfg=21 ctermbg=226
highlight SignColumn guifg=#00ffff guibg=#c0c0c0 ctermfg=51 ctermbg=250
highlight Special guifg=#ff00ff ctermfg=201
highlight SpecialKey guifg=#00aea0 guibg=#22302d ctermfg=37 ctermbg=236
highlight SpellBad gui=undercurl cterm=undercurl
highlight SpellCap gui=undercurl cterm=undercurl
highlight SpellLocal gui=undercurl cterm=undercurl
highlight SpellRare gui=undercurl cterm=undercurl
highlight Statement guifg=#00a0e0 ctermfg=39
highlight StatusLine guifg=#00c4ff guibg=#000000 gui=reverse ctermfg=81 ctermbg=16 cterm=reverse
highlight StatusLineNC guifg=#a4a4ff guibg=#444400 ctermfg=147 ctermbg=58
highlight TabLine guifg=#0066ff guibg=#001133 ctermfg=27 ctermbg=17
highlight TabLineFill gui=NONE cterm=NONE
highlight TabLineSel guifg=#999944 guibg=#112233 gui=underline ctermfg=143 ctermbg=234 cterm=underline
highlight Title guifg=#ffff44 ctermfg=227
highlight Todo guifg=#ff0000 guibg=#112233 gui=bold,underline ctermfg=196 ctermbg=234 cterm=bold,underline
highlight Type guifg=#ff9933 ctermfg=208
highlight Underlined gui=underline cterm=underline
highlight VertSplit guifg=#00c4ff guibg=#0000ff gui=reverse ctermfg=81 ctermbg=21 cterm=reverse
highlight Visual guibg=#223344 ctermbg=236
highlight VisualNOS gui=NONE cterm=NONE
highlight WarningMsg guifg=#ffa500 guibg=#000080 ctermfg=214 ctermbg=18
highlight WildMenu gui=NONE cterm=NONE
hi link Boolean Constant
hi link Character Constant
hi link Conditional Statement
hi link CursorColumn CursorLine
hi link Debug Special
hi link Define PreProc
hi link Delimiter Special
hi link Exception Statement
hi link Float Constant
hi link Function Identifier
hi link Include PreProc
hi link Keyword Statement
hi link Label Statement
hi link Macro PreProc
hi link Number Constant
hi link Operator Statement
hi link PreCondit PreProc
hi link Repeat Statement
hi link SpecialChar Special
hi link SpecialComment Special
hi link StorageClass Type
hi link String Constant
hi link Structure Type
hi link Tag Special
hi link Typedef Type
