" 本配色方案由 gui2term.py 程序增加彩色终端支持。

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" File Name:      spring.vim
" Abstract:       A color sheme file (only for GVIM), which make the VIM 
"                 bright with colors. It looks like the flowers are in 
"                 blossom in Spring.
" Author:         CHE Wenlong <chewenlong AT buaa.edu.cn>
" Contributor:    lilydjwg <lilydjwg@gmail.com>
" Version:        1.1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set background=light

" Version control
if version > 580
  hi clear
  if exists("syntax_on")
	syntax reset
  endif
endif

let colors_name = "spring2"

" Common
highlight Normal ctermbg=194 cterm=none guibg=#cce8cf gui=none ctermfg=16 guifg=#000000
highlight Visual guibg=#ccffff gui=none ctermbg=195 cterm=none
highlight Cursor ctermbg=23 cterm=none guibg=#2f4f4f gui=none ctermfg=223 guifg=#f5deb3
highlight CursorLine guibg=#ccffff ctermbg=195 cterm=none
highlight CursorLineNr guifg=#1060a0 guibg=#ccffff ctermfg=25 ctermbg=195 cterm=none
highlight LineNr ctermbg=254 cterm=none guibg=#e0e0e0 gui=none ctermfg=25 guifg=#1060a0
highlight Title gui=bold cterm=bold guifg=#202020 ctermfg=234
highlight Underlined gui=underline cterm=underline guifg=#202020 ctermfg=234

" Split
highlight StatusLine ctermbg=23 cterm=bold guibg=#2f4f4f gui=bold ctermfg=223 guifg=#f5deb3
highlight StatusLineNC ctermbg=23 cterm=none guibg=#2f4f4f gui=none ctermfg=223 guifg=#f5deb3
highlight VertSplit ctermbg=23 cterm=none guibg=#2f4f4f gui=none ctermfg=23 guifg=#2f4f4f

" Folder
highlight Folded ctermbg=254 cterm=none guibg=#e0e0e0 gui=none ctermfg=24 guifg=#006699

" Syntax
highlight Type gui=bold cterm=bold guifg=#009933 ctermfg=28
highlight Define gui=bold cterm=bold guifg=#1060a0 ctermfg=25
highlight Comment gui=none cterm=none guifg=#1e90ff ctermfg=33
highlight Constant gui=none cterm=none guifg=#a07040 ctermfg=137
highlight String gui=none cterm=none guifg=#a07040 ctermfg=137
highlight Number gui=none cterm=none guifg=#cd0000 ctermfg=160
highlight Statement gui=bold cterm=bold guifg=#fc548f ctermfg=204

" Others
highlight PreProc gui=none cterm=none guifg=#1060a0 ctermfg=25
highlight Error ctermbg=231 cterm=bold,underline guibg=#ffffff gui=bold,underline ctermfg=196 guifg=#ff0000
highlight Todo gui=bold,underline cterm=bold,underline guifg=#a0b0c0 ctermfg=110
highlight Special gui=none cterm=none guifg=#8b038d ctermfg=90
highlight SpecialKey ctermbg=254 cterm=none guibg=#e8e8e8 gui=none ctermfg=180 guifg=#d8a080

if v:version >= 700
highlight TabLine guibg=#dce8dc gui=none ctermbg=254 cterm=none
highlight TabLineFill guifg=#e8e8e8 ctermfg=254
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
