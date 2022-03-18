" ingo/area.vim: Functions to deal with areas.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#area#IsEmpty( area )
"******************************************************************************
"* PURPOSE:
"   Test whether a:area is empty (or even invalid, with the end before the
"   start). Does not check whether the positions actually exist in the current
"   buffer.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:area  [[startLnum, startCol], [endLnum, endCol]]
"* RETURN VALUES:
"   1 if area is valid and covers at least one character, 0 otherwise.
"******************************************************************************
    if empty(a:area)
	return 1
    elseif a:area[0][0] == 0 || a:area[1][0] == 0
	return 1
    elseif a:area[0][0] > a:area[1][0]
	return 1
    elseif a:area[0][0] == a:area[1][0] && a:area[0][1] > a:area[1][1]
	return 1
    endif
    return 0
endfunction

function! ingo#area#EmptyArea( pos ) abort
    return [a:pos, ingo#pos#Before(a:pos)]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
