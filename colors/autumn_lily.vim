" 本配色方案由 gui2term.py 程序增加彩色终端支持。
" Vim color file
"  Maintainer: Tiza
" Last Change: 2002/10/14 Mon 16:41.
"     version: 1.0
" This color scheme uses a light background.

set background=light
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "autumn"

hi Normal       guifg=#404040 guibg=#fff4e8 ctermfg=238 ctermbg=230 cterm=none

" Search
hi IncSearch    gui=UNDERLINE guifg=#404040 guibg=#e0e040 ctermfg=238 ctermbg=227 cterm=underline
hi Search       gui=NONE guifg=#544060 guibg=#f0c0ff ctermfg=96 ctermbg=219 cterm=none

" Messages
hi ErrorMsg     gui=BOLD guifg=#f8f8f8 guibg=#4040ff ctermfg=231 ctermbg=63 cterm=bold
hi WarningMsg   gui=BOLD guifg=#f8f8f8 guibg=#4040ff ctermfg=231 ctermbg=63 cterm=bold
hi ModeMsg      gui=NONE guifg=#d06000 guibg=NONE ctermfg=166 ctermbg=230 cterm=none
hi MoreMsg      gui=NONE guifg=#0090a0 guibg=NONE ctermfg=37 ctermbg=230 cterm=none
hi Question     gui=NONE guifg=#8000ff guibg=NONE ctermfg=93 ctermbg=230 cterm=none

" Split area
hi StatusLine   gui=BOLD guifg=#f8f8f8 guibg=#904838 ctermfg=231 ctermbg=131 cterm=bold
hi StatusLineNC gui=BOLD guifg=#c0b0a0 guibg=#904838 ctermfg=138 ctermbg=131 cterm=bold
hi VertSplit    gui=NONE guifg=#f8f8f8 guibg=#904838 ctermfg=231 ctermbg=131 cterm=none
hi WildMenu     gui=BOLD guifg=#f8f8f8 guibg=#ff3030 ctermfg=231 ctermbg=203 cterm=bold

" Diff
hi DiffText     gui=NONE guifg=#2850a0 guibg=#c0d0f0 ctermfg=25 ctermbg=189 cterm=none
hi DiffChange   gui=NONE guifg=#208040 guibg=#c0f0d0 ctermfg=28 ctermbg=194 cterm=none
hi DiffDelete   gui=NONE guifg=#ff2020 guibg=#eaf2b0 ctermfg=196 ctermbg=229 cterm=none
hi DiffAdd      gui=NONE guifg=#ff2020 guibg=#eaf2b0 ctermfg=196 ctermbg=229 cterm=none

" Cursor
hi Cursor       gui=NONE guifg=#ffffff guibg=#0080f0 ctermfg=231 ctermbg=33 cterm=none
hi lCursor      gui=NONE guifg=#ffffff guibg=#8040ff
hi CursorIM     gui=NONE guifg=#ffffff guibg=#8040ff ctermfg=231 ctermbg=99 cterm=none
hi CursorLine   gui=NONE guibg=#e5e5e5 ctermbg=254 cterm=none
hi link CursorColumn CursorLine

" Fold
hi Folded       gui=NONE guifg=#804030 guibg=#ffc0a0 ctermfg=131 ctermbg=223 cterm=none
hi FoldColumn   gui=NONE guifg=#a05040 guibg=#f8d8c4 ctermfg=131 ctermbg=224 cterm=none

" Other
hi Directory    gui=NONE guifg=#7050ff guibg=NONE ctermfg=99 ctermbg=230 cterm=none
hi LineNr       gui=NONE guifg=#e0b090 guibg=NONE ctermfg=180 ctermbg=230 cterm=none
hi NonText      gui=BOLD guifg=#a05040 guibg=#ffe4d4 ctermfg=131 ctermbg=224 cterm=bold
hi SpecialKey   gui=NONE guifg=#0080ff guibg=NONE ctermfg=33 ctermbg=230 cterm=none
hi Title        gui=BOLD guifg=fg      guibg=NONE ctermfg=238 ctermbg=none cterm=bold
hi Visual       gui=NONE guifg=#804020 guibg=#ffc0a0 ctermfg=88 ctermbg=223 cterm=none
" hi VisualNOS  gui=NONE guifg=#604040 guibg=#e8dddd

" Syntax group
hi Comment      gui=NONE guifg=#ff5050 guibg=NONE ctermfg=203 ctermbg=230 cterm=none
hi Constant     gui=NONE guifg=#00884c guibg=NONE ctermfg=29 ctermbg=230 cterm=none
hi Error        gui=BOLD guifg=#f8f8f8 guibg=#4040ff ctermfg=231 ctermbg=63 cterm=bold
hi Identifier   gui=NONE guifg=#b07800 guibg=NONE ctermfg=136 ctermbg=230 cterm=none
hi Ignore       gui=NONE guifg=bg guibg=NONE ctermfg=230 ctermbg=230 cterm=none
hi PreProc      gui=NONE guifg=#0090a0 guibg=NONE ctermfg=37 ctermbg=230 cterm=none
hi Special      gui=NONE guifg=#8040f0 guibg=NONE ctermfg=99 ctermbg=230 cterm=none
hi Statement    gui=BOLD guifg=#80a030 guibg=NONE ctermfg=107 ctermbg=230 cterm=bold
hi Todo         gui=BOLD,UNDERLINE guifg=#0080f0 guibg=NONE ctermfg=33 ctermbg=230 cterm=bold,underline
hi Type         gui=BOLD guifg=#b06c58 guibg=NONE ctermfg=131 ctermbg=230 cterm=bold
hi Underlined   gui=UNDERLINE guifg=blue guibg=NONE ctermfg=21 ctermbg=230 cterm=underline
