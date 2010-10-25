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

hi clear

" Version control
if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let colors_name = "spring2"

" Common
hi Normal           guifg=#000000   guibg=#cce8cf   gui=NONE ctermfg=16 ctermbg=151 cterm=none
hi Visual           guibg=#ccffff                   gui=NONE ctermbg=195 cterm=none
hi Cursor           guifg=#f5deb3   guibg=#2f4f4f   gui=NONE ctermfg=223 ctermbg=66 cterm=none
hi Cursorline       guibg=#ccffff ctermbg=195 cterm=none
hi lCursor          guifg=#000000   guibg=#ffffff   gui=NONE
hi LineNr           guifg=#1060a0   guibg=#e0e0e0   gui=NONE ctermfg=25 ctermbg=254 cterm=none
hi Title            guifg=#202020   guibg=NONE      gui=bold ctermfg=234 ctermbg=none cterm=bold
hi Underlined       guifg=#202020   guibg=NONE      gui=underline ctermfg=234 ctermbg=151 cterm=underline

" Split
hi StatusLine       guifg=#f5deb3   guibg=#2f4f4f   gui=bold ctermfg=223 ctermbg=66 cterm=bold
hi StatusLineNC     guifg=#f5deb3   guibg=#2f4f4f   gui=NONE ctermfg=223 ctermbg=66 cterm=none
hi VertSplit        guifg=#2f4f4f   guibg=#2f4f4f   gui=NONE ctermfg=66 ctermbg=66 cterm=none

" Folder
hi Folded           guifg=#006699   guibg=#e0e0e0   gui=NONE ctermfg=24 ctermbg=254 cterm=none

" Syntax
hi Type             guifg=#009933   guibg=NONE      gui=bold ctermfg=28 ctermbg=151 cterm=bold
hi Define           guifg=#1060a0   guibg=NONE      gui=bold ctermfg=25 ctermbg=151 cterm=bold
hi Comment          guifg=#1e90ff   guibg=NONE      gui=NONE ctermfg=33 ctermbg=151 cterm=none
hi Constant         guifg=#a07040   guibg=NONE      gui=NONE ctermfg=137 ctermbg=151 cterm=none
hi String           guifg=#a07040   guibg=NONE      gui=NONE ctermfg=137 ctermbg=151 cterm=none
hi Number           guifg=#cd0000   guibg=NONE      gui=NONE ctermfg=160 ctermbg=151 cterm=none
hi Statement        guifg=#fc548f   guibg=NONE      gui=bold ctermfg=204 ctermbg=151 cterm=bold

" Others
hi PreProc          guifg=#1060a0    guibg=NONE     gui=NONE ctermfg=25 ctermbg=151 cterm=none
hi Error            guifg=#ff0000    guibg=#ffffff  gui=bold,underline ctermfg=196 ctermbg=231 cterm=bold,underline
hi Todo             guifg=#a0b0c0    guibg=NONE     gui=bold,underline ctermfg=103 ctermbg=151 cterm=bold,underline
hi Special          guifg=#8B038D    guibg=NONE     gui=NONE ctermfg=90 ctermbg=151 cterm=none
hi SpecialKey       guifg=#d8a080    guibg=#e8e8e8  gui=NONE ctermfg=180 ctermbg=254 cterm=none

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
