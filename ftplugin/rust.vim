" Vim script file
" FileType:     rust
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
" default is 99 which is too wide for my monitor
setlocal textwidth=78
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
