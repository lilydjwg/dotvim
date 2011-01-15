" 本配色方案由 gui2term.py 程序增加彩色终端支持。

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" File Name:      spring.vim
" Abstract:       A color sheme file (only for GVIM), which make the VIM 
"                 bright with colors. It looks like the flowers are in 
"                 blossom in Spring.
" Author:         CHE Wenlong <chewenlong AT buaa.edu.cn>
" Version:        1.0
" Last Change:    September 16, 2008

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
highlight Normal       ctermbg=151           cterm=none           guibg=#cce8cf gui=none           ctermfg=16  guifg=#000000
highlight Visual       guibg=#ccffff         gui=none             ctermbg=195   cterm=none
highlight Cursor       ctermbg=66            cterm=none           guibg=#2f4f4f gui=none           ctermfg=223 guifg=#f5deb3
highlight Cursorline   guibg=#ccffff         ctermbg=195          cterm=none
hi        lCursor      guifg=#000000         guibg=#ffffff        gui=NONE
highlight LineNr       ctermbg=254           cterm=none           guibg=#e0e0e0 gui=none           ctermfg=25  guifg=#1060a0
highlight Title        cterm=bold            gui=bold             ctermfg=234   guifg=#202020
highlight Underlined   cterm=underline       gui=underline        ctermfg=234   guifg=#202020

" Split
highlight StatusLine   ctermbg=66            cterm=bold           guibg=#2f4f4f gui=bold           ctermfg=223 guifg=#f5deb3
highlight StatusLineNC ctermbg=66            cterm=none           guibg=#2f4f4f gui=none           ctermfg=223 guifg=#f5deb3
highlight VertSplit    ctermbg=66            cterm=none           guibg=#2f4f4f gui=none           ctermfg=66  guifg=#2f4f4f

" Folder
highlight Folded       ctermbg=254           cterm=none           guibg=#e0e0e0 gui=none           ctermfg=24  guifg=#006699

" Syntax
highlight Type         cterm=bold            gui=bold             ctermfg=28    guifg=#009933
highlight Define       cterm=bold            gui=bold             ctermfg=25    guifg=#1060a0
highlight Comment      cterm=none            gui=none             ctermfg=33    guifg=#1e90ff
highlight Constant     cterm=none            gui=none             ctermfg=137   guifg=#a07040
highlight String       cterm=none            gui=none             ctermfg=137   guifg=#a07040
highlight Number       cterm=none            gui=none             ctermfg=160   guifg=#cd0000
highlight Statement    cterm=bold            gui=bold             ctermfg=204   guifg=#fc548f

" Others
highlight PreProc      cterm=none            gui=none             ctermfg=25    guifg=#1060a0
highlight Error        ctermbg=231           cterm=bold,underline guibg=#ffffff gui=bold,underline ctermfg=196 guifg=#ff0000
highlight Todo         cterm=bold,underline  gui=bold,underline   ctermfg=103   guifg=#a0b0c0
highlight Special      cterm=none            gui=none             ctermfg=90    guifg=#8b038d
highlight SpecialKey   ctermbg=254           cterm=none           guibg=#e8e8e8 gui=none           ctermfg=180 guifg=#d8a080

if v:version >= 700
          highlight    TabLine               guibg=#dce8dc        gui=none      ctermbg=254        cterm=none
          highlight    TabLineFill           guifg=#e8e8e8        ctermfg=254
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
