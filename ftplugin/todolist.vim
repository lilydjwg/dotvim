" todolist.vim  Todo list, GTD
" Author:       lilydjwg
" Maintainer:   lilydjwg <lilydjwg@gmail.com>
" Last Change:  2009年9月11日
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1
let s:keepcpo = &cpo
let g:loaded_todolist = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function! s:update()
  python td.update()
endfunction
" ---------------------------------------------------------------------
" Command:
com! -buffer Save call s:update()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
