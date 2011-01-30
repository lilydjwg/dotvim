" Vim script file
" FileType:     git commit
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011-01-30

" ---------------------------------------------------------------------
"  排版
setlocal fo-=c
setlocal nomodeline
"  置于第一行
0
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
