" ingo/range/sort.vim: Functions for sorting ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#range#sort#AscendingByStartLnum( ranges ) abort
"******************************************************************************
"* PURPOSE:
"   Sort ranges ascending by start line number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:ranges    List of [start, end] pairs.
"* RETURN VALUES:
"   List of [start, end] pairs in ascending order.
"******************************************************************************
    return sort(a:ranges, function('ingo#collections#SortOnFirstListElement'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
