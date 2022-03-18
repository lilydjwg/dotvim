" ingo/list/reduce.vim: Functions for reducing lists to single scalar values.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#list#reduce#Sum( list ) abort
    return ingo#collections#Reduce(a:list, 'v:val[0] + v:val[1]', 0)
endfunction

function! ingo#list#reduce#Product( list ) abort
    return ingo#collections#Reduce(a:list, 'v:val[0] * v:val[1]', 1)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
