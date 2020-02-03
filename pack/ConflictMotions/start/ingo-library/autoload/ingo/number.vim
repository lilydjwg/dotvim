" ingo/number.vim: Functions for dealing with numbers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.005.001	12-Apr-2013	file creation

function! ingo#number#DecimalStringIncrement( number, offset )
"******************************************************************************
"* PURPOSE:
"   Increment the decimal number in a:number by a:offset while keeping (the
"   width of) leading zeros.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    String (or number) to be incremented.
"   a:offset    Offset to add to a:number.
"* RETURN VALUES:
"   Incremented number as String.
"******************************************************************************
    " Note: Need to use str2nr() to avoid interpreting leading zeros as octal
    " number.
    return printf('%0' . strlen(a:number) . 'd', str2nr(a:number) + a:offset)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
