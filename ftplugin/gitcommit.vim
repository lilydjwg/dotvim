" Vim script file
" FileType:     git commit
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-21

" ---------------------------------------------------------------------
"  自动排版
setlocal fo+=a
setlocal fo-=c
"  置于第一行
0
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
