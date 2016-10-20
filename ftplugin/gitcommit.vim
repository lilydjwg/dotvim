" Vim script file
" FileType:     git commit
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
setlocal iskeyword+=-
"  排版
setlocal fo-=c
setlocal nomodeline
"  置于第一行
0
runtime ftplugin/diff_movement.vim
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
