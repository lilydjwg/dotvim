" ingo/lnum.vim: Functions to work with line numbers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#lnum#AddOffsetWithWrapping( lnum, offset, ... )
"******************************************************************************
"* PURPOSE:
"   Add a:offset to a:lnum; if the result is less than 1 or larger than
"   a:maxLnum, wrap around.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum      Source line number.
"   a:offset    Positive or negative offset to apply to a:lnum.
"   a:maxLnum   Maximum allowed line number; defaults to line('$'), the last
"               line of the current buffer.
"* RETURN VALUES:
"   1 <= result <= a:maxLnum
"******************************************************************************
    let l:lnum = a:lnum + a:offset
    let l:maxLnum = (a:0 ? a:1 : line('$'))

    if l:lnum < 1
	return l:maxLnum + l:lnum % l:maxLnum
    elseif l:lnum > l:maxLnum
	return l:lnum % l:maxLnum
    else
	return l:lnum
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
