" Vim script file
" FileType:     git commit
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-13

" ---------------------------------------------------------------------
"  自动排版
setlocal fo+=a
setlocal fo-=c
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
