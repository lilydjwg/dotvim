" ingo/list/transform.vim: Functions to transform list elements.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#list#transform#str2nr( list, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Convert elements of a:list to numbers (replacing the original items).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list      Source list.
"   a:base      Optional conversion base.
"   a:quoted    Flag whether embedded single quotes are ignored.
"* RETURN VALUES:
"   The modified a:list.
"******************************************************************************
    if a:0 > 0
	return map(a:list, 'call("str2nr", [v:val] + a:000)')
    else
	return map(a:list, 'str2nr(v:val)')
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
