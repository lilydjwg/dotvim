" ingo/binary.vim: Functions for working with binary numbers.
"
" DEPENDENCIES:
"   - nary.vim autoload script
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.002	14-May-2017	Generalize functions into ingo/nary.vim and
"				delegate ingo#binary#...() functions to those.
"   1.029.001	28-Dec-2016	file creation

function! ingo#binary#FromNumber( number, ... )
"******************************************************************************
"* PURPOSE:
"   Turn the integer a:number into a (little-endian) List of boolean values.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Positive integer.
"   a:bitNum    Optional number of bits to use. If specified and a:number cannot
"		be represented by it, a exception is thrown. If a:bitNum is
"		negative, only the lower bits will be returned. If omitted, the
"		minimal amount of bits is used.
"* RETURN VALUES:
"   List of [b0, b1, b2, ...] boolean values; lowest bits come first.
"******************************************************************************
    return call('ingo#nary#FromNumber', [2, a:number] + a:000)
endfunction
function! ingo#binary#ToNumber( bits )
"******************************************************************************
"* PURPOSE:
"   Turn the (little-endian) List of boolean values into a number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:bits  List of [b0, b1, b2, ...] boolean values; lowest bits come first.
"* RETURN VALUES:
"   Positive integer represented by a:bits.
"******************************************************************************
    return call('ingo#nary#ToNumber', [2, a:bits] + a:000)
endfunction

function! ingo#binary#BitsRequired( number )
"******************************************************************************
"* PURPOSE:
"   Determine the number of bits required to represent a:number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Positive integer.
"* RETURN VALUES:
"   Number of bits required to represent numbers between 0 and a:number.
"******************************************************************************
    return ingo#nary#ElementsRequired(2, a:number)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
