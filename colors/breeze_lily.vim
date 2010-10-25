" 本配色方案由 gui2term.py 程序增加彩色终端支持。
" Vim color file
"  Maintainer: Tiza
"  Modified By: lilydjwg <lilydjwg@gmail.com>
" Last Change: 2009年8月8日
"     version: 1.0
" This color scheme uses a dark background.

set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "breeze"

hi Normal       guifg=#ffffff guibg=#005c70 ctermfg=231 ctermbg=23 cterm=none

" Search
hi IncSearch    gui=UNDERLINE guifg=#60ffff guibg=#6060ff ctermfg=87 ctermbg=63 cterm=underline
hi Search       gui=NONE guifg=#ffffff guibg=#6060ff ctermfg=231 ctermbg=63 cterm=none

" Messages
hi ErrorMsg     gui=BOLD guifg=#ffffff guibg=#ff40a0 ctermfg=231 ctermbg=205 cterm=bold
hi WarningMsg   gui=BOLD guifg=#ffffff guibg=#ff40a0 ctermfg=231 ctermbg=205 cterm=bold
hi ModeMsg      gui=NONE guifg=#60ffff guibg=NONE ctermfg=87 ctermbg=23 cterm=none
hi MoreMsg      gui=NONE guifg=#ffc0ff guibg=NONE ctermfg=219 ctermbg=23 cterm=none
hi Question     gui=NONE guifg=#ffff60 guibg=NONE ctermfg=227 ctermbg=23 cterm=none

" Split area
hi StatusLine   gui=NONE guifg=#000000 guibg=#d0d0e0 ctermfg=16 ctermbg=146 cterm=none
hi StatusLineNC gui=NONE guifg=#606080 guibg=#d0d0e0 ctermfg=60 ctermbg=146 cterm=none
hi VertSplit    gui=NONE guifg=#606080 guibg=#d0d0e0 ctermfg=60 ctermbg=146 cterm=none
hi WildMenu     gui=NONE guifg=#000000 guibg=#00c8f0 ctermfg=16 ctermbg=45 cterm=none

" Diff
hi DiffText     gui=UNDERLINE guifg=#ffff00 guibg=#000000 ctermfg=226 ctermbg=16 cterm=underline
hi DiffChange   gui=NONE guifg=#ffffff guibg=#000000 ctermfg=231 ctermbg=16 cterm=none
hi DiffDelete   gui=NONE guifg=#60ff60 guibg=#000000 ctermfg=83 ctermbg=16 cterm=none
hi DiffAdd      gui=NONE guifg=#60ff60 guibg=#000000 ctermfg=83 ctermbg=16 cterm=none

" Cursor
hi Cursor       gui=NONE guifg=#ffffff guibg=#d86020 ctermfg=231 ctermbg=166 cterm=none
hi lCursor      gui=NONE guifg=#ffffff guibg=#e000b0
hi CursorIM     gui=NONE guifg=#ffffff guibg=#e000b0 ctermfg=231 ctermbg=163 cterm=none
hi CursorLine	guibg=#303030 ctermbg=236 cterm=none
hi link CursorColumn CursorLine

" Fold
hi Folded       gui=NONE guifg=#ffffff guibg=#0088c0 ctermfg=231 ctermbg=31 cterm=none
" hi Folded       gui=NONE guifg=#ffffff guibg=#2080d0
hi FoldColumn   gui=NONE guifg=#60e0e0 guibg=#006c7f ctermfg=80 ctermbg=24 cterm=none

" Other
hi Directory    gui=NONE guifg=#00e0ff guibg=NONE ctermfg=45 ctermbg=23 cterm=none
hi LineNr       gui=NONE guifg=#60a8bc guibg=NONE ctermfg=73 ctermbg=23 cterm=none
hi NonText      gui=BOLD guifg=#00c0c0 guibg=#006276 ctermfg=37 ctermbg=24 cterm=bold
hi SpecialKey   gui=NONE guifg=#e0a0ff guibg=NONE ctermfg=183 ctermbg=23 cterm=none
hi Title        gui=BOLD guifg=#ffffff guibg=NONE ctermfg=231 ctermbg=23 cterm=bold
hi Visual       gui=NONE guifg=#ffffff guibg=#6060d0 ctermfg=231 ctermbg=62 cterm=none
" hi VisualNOS  gui=NONE guifg=#ffffff guibg=#6060d0

" Syntax group
hi Comment      gui=NONE guifg=#c8d0d0 guibg=NONE ctermfg=152 ctermbg=23 cterm=none
hi Constant     gui=NONE guifg=#60ffff guibg=NONE ctermfg=87 ctermbg=23 cterm=none
hi Error        gui=BOLD guifg=#ffffff guibg=#ff40a0 ctermfg=231 ctermbg=205 cterm=bold
hi Identifier   gui=NONE guifg=#cacaff guibg=NONE ctermfg=189 ctermbg=23 cterm=none
hi Ignore       gui=NONE guifg=#006074 guibg=NONE ctermfg=24 ctermbg=23 cterm=none
hi PreProc      gui=NONE guifg=#ffc0ff guibg=NONE ctermfg=219 ctermbg=23 cterm=none
hi Special      gui=NONE guifg=#ffd074 guibg=NONE ctermfg=222 ctermbg=23 cterm=none
hi Statement    gui=NONE guifg=#ffff80 guibg=NONE ctermfg=228 ctermbg=23 cterm=none
hi Todo         gui=BOLD,UNDERLINE guifg=#ffb0b0 guibg=NONE ctermfg=217 ctermbg=23 cterm=bold,underline
hi Type         gui=NONE guifg=#80ffa0 guibg=NONE ctermfg=121 ctermbg=23 cterm=none
hi Underlined   gui=UNDERLINE guifg=#ffffff guibg=NONE ctermfg=231 ctermbg=23 cterm=underline
