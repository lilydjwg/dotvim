" Vim script file
" FileType:     rust
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
" default is 99 which is too wide for my monitor
setlocal textwidth=78
let g:rust_use_custom_ctags_defs = 1
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
