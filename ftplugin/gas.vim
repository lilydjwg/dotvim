" Vim script file
" FileType:     gas
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
setlocal ai
setlocal iskeyword+=$
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
